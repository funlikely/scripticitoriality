import requests
import time
import sys

INPUT_FILE = "pix_input.txt"
OUTPUT_FILE = "pix_output.txt"

HEADERS = {
    "User-Agent": "Mozilla/5.0",
    "Referer": "https://www.pixiv.net/"
}

def is_valid_pixiv_user(user_id):
    url = f"https://www.pixiv.net/users/{user_id}"
    try:
        r = requests.get(url, headers=HEADERS, timeout=10)
        # Pixiv returns 200 for valid users
        return r.status_code == 200
    except requests.RequestException:
        return False


def main():
    with open(INPUT_FILE, "r") as f:
        content = f.read()

    ids = content.split()

    valid = []
    invalid = []

    for user_id in ids:
        if is_valid_pixiv_user(user_id):
            valid.append(user_id)
            print(f"{user_id} -> valid")
        else:
            invalid.append(user_id)
            print(f"{user_id} -> invalid")

        time.sleep(0.5)  # be gentle, avoid rate limiting

    with open(OUTPUT_FILE, "w") as f:
        f.write("valid\n")
        f.write(" ".join(valid) + "\n")
        f.write("invalid\n")
        f.write(" ".join(invalid) + "\n")


if __name__ == "__main__":
    main()