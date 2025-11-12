import os
import time
import requests
import subprocess

AWS_IP = os.environ.get("AWS_IP", "98.92.236.193")
GCP_IP = os.environ.get("GCP_IP", "136.116.113.101")
DNSMASQ_CONF = "/etc/dnsmasq.conf"
PORT = os.environ.get("DNS_PORT", "53535")
INTERVAL = int(os.environ.get("INTERVAL", "5"))
TIMEOUT = float(os.environ.get("TIMEOUT", "2.0"))
DOMAIN_APP = os.environ.get("DOMAIN_APP", "app.multi.local")
DOMAIN_AWS = os.environ.get("DOMAIN_AWS", "aws.multi.local")
DOMAIN_GCP = os.environ.get("DOMAIN_GCP", "gcp.multi.local")
ALERT = os.environ.get("ALERT", "ALL BACKENDS DOWN")

CHECK_URL = "http://{ip}"
last_reload_time = 0

def is_alive(ip):
    try:
        r = requests.get(CHECK_URL.format(ip=ip), timeout=TIMEOUT)
        return r.status_code == 200
    except Exception:
        return False

def write_conf(ip):
    lines = [
        f"port={PORT}\n",
        "no-resolv\n",
        "no-hosts\n",
        "interface=*\n",
        "listen-address=127.0.0.1\n",
        "bind-interfaces\n",
        "log-queries\n",
        "log-facility=/var/log/dnsmasq.log\n",
        "cache-size=0\n",
        "local-ttl=1\n",
        "\n",
        f"address=/{DOMAIN_APP}/{ip}\n",
        f"address=/{DOMAIN_AWS}/{AWS_IP}\n",
        f"address=/{DOMAIN_GCP}/{GCP_IP}\n",
    ]
    with open(DNSMASQ_CONF, "w") as f:
        f.writelines(lines)
    print(f"[WATCHDOG] Updated dnsmasq.conf -> app.multi.local → {ip}")

def reload_dnsmasq():
    try:
        print("[WATCHDOG] Restarting dnsmasq manually...")
        subprocess.run(["pkill", "-9", "dnsmasq"], check=False)
        time.sleep(0.3)
        subprocess.Popen(["/usr/sbin/dnsmasq", "--no-daemon", "--conf-file=/etc/dnsmasq.conf"])
        print("[WATCHDOG] dnsmasq restarted successfully.")
        return True
    except Exception as e:
        print("[WATCHDOG] Failed to restart dnsmasq:", e)
        return False

def verify_answer(expected_ip):
    try:
        dig_cmd = ["dig", "@127.0.0.1", "-p", str(PORT), DOMAIN_APP, "+short"]
        p = subprocess.run(dig_cmd, capture_output=True, text=True, timeout=3)
        out = p.stdout.strip()
        actual = out.splitlines()[0].strip() if out else None
        print(f"[WATCHDOG] dig result: {actual}")
        return actual == expected_ip
    except Exception as e:
        print("[WATCHDOG] verify dig failed:", e)
        return False

def set_active(ip):
    write_conf(ip)
    if reload_dnsmasq():
        time.sleep(0.5)
        if verify_answer(ip):
            print(f"[WATCHDOG] Verified DNS now points to {ip}")
        else:
            print(f"[WATCHDOG] DNS still not matching {ip} — retrying hard restart.")
            subprocess.run(["supervisorctl", "restart", "dnsmasq"], check=False)
            time.sleep(1)
            verify_answer(ip)

def main():
    last_ip = None
    time.sleep(2)
    while True:
        aws_ok = is_alive(AWS_IP)
        gcp_ok = is_alive(GCP_IP)

        if aws_ok:
            active_ip = AWS_IP
            src = "AWS"
        elif gcp_ok:
            active_ip = GCP_IP
            src = "GCP"
        else:
            active_ip = None
            src = "NONE"

        if active_ip != last_ip:
            print(f"[WATCHDOG] Switchover: active backend → {src} ({active_ip})")
            if active_ip:
                set_active(active_ip)
            else:
                print(f"[WATCHDOG] {ALERT}")
            last_ip = active_ip

        time.sleep(INTERVAL)

if __name__ == "__main__":
    main()