import requests
import json
import os
import time


# API-Schlüssel sicher speichern (z.B. in einer .env-Datei)
API_KEY = "nORfMs2PcN8pkjeLiTP0t9IU5I8MfWnMOG3qV6QmFqlHI3iPew3p43CcqzOD9TGr"


def upload_receipt(api_key, image_path):
    endpoint = "https://api.tabscanner.com/api/2/process"

    if not os.path.isfile(image_path):
        print(f"Fehler: Die Datei existiert nicht: {image_path}")
        return None

    payload = {"documentType": "receipt"}
    headers = {'apikey': api_key}

    try:
        with open(image_path, 'rb') as image_file:
            files = {'file': image_file}
            response = requests.post(endpoint, files=files, data=payload, headers=headers)
        
        if response.status_code == 200:
            result = response.json()
            token = result.get('token')
            print(f"Upload erfolgreich. Token: {token}")
            return token
        else:
            print(f"Fehler beim Hochladen: HTTP {response.status_code}")
            print(response.text)
            return None

    except Exception as e:
        print(f"Ein Fehler ist aufgetreten: {e}")
        return None


def get_receipt_result(token, api_key, max_retries=30, retry_interval=2):
    url = f"https://api.tabscanner.com/api/result/{token}"
    headers = {'apikey': api_key}

    print("Starte Ergebnisabfrage...")

    for attempt in range(max_retries):
        try:
            response = requests.get(url, headers=headers)
            if response.status_code == 200:
                result = response.json()
                status = result.get('status', '').lower()
                print(f"Status: {status}")

                if status in ['completed', 'done']:
                    return result

                if status == 'failed':
                    error_message = result.get('error', 'Keine Fehlermeldung verfügbar.')
                    print(f"Fehler bei der Verarbeitung: {error_message}")
                    return None

                print("Verarbeitung läuft...")
            else:
                print(f"HTTP-Fehler: {response.status_code}")
                print(response.text)
                return None

        except Exception as e:
            print(f"Ein Fehler ist aufgetreten: {e}")
            return None

        time.sleep(retry_interval)

    print("Maximale Anzahl an Versuchen erreicht. Abbruch.")
    return None


def main():
    current_dir = os.path.dirname(os.path.abspath(__file__))
    image_path = os.path.join(current_dir, 'receipts_imgs', 'receipt2.jpg')

    token = upload_receipt(API_KEY, image_path)
    result = get_receipt_result(token, API_KEY)
    print(json.dumps(result, indent=4, ensure_ascii=False))

if __name__ == '__main__':
    main()
