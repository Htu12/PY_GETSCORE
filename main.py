import requests
import mysql.connector
from mysql.connector import Error
import time

# Các tham số kết nối cơ sở dữ liệu
db_config = {
    'host': 'localhost',
    'port': '3307',
    'user': 'root',
    'password': '123456',
    'database': 'diemthi'
}

# Hàm để chèn dữ liệu vào MySQL
def insert_data(data):
    try:
        conn = mysql.connector.connect(**db_config)  
        cursor = conn.cursor()  
        insert_query = """
        INSERT INTO exam_results (candidate_number, mon_toan, mon_van, mon_ly, mon_hoa, mon_sinh, mon_su, mon_dia, mon_gdcd, mon_ngoaingu, ma_mon_ngoai_ngu, mark_info, data_year)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """  
        cursor.execute(insert_query, (
            data['candidate_number'], data['mon_toan'], data['mon_van'], data['mon_ly'], data['mon_hoa'], data['mon_sinh'],
            data['mon_su'], data['mon_dia'], data['mon_gdcd'], data['mon_ngoaingu'], data['ma_mon_ngoai_ngu'], data['mark_info'], data['data_year']
        ))  
        conn.commit()  
    except Error as e:
        print(f"Error: {e}")  
    finally:
        if conn.is_connected():
            cursor.close()  
            conn.close()  

# Hàm để ghi số báo danh lỗi vào file
def log_failed_sbd(sbd):
    with open("failed_sbd.txt", "a") as file:
        file.write(f"{sbd}\n")

# Hàm để đọc số báo danh lỗi từ file
def read_failed_sbd():
    try:
        with open("failed_sbd.txt", "r") as file:
            return [line.strip() for line in file.readlines()]
    except FileNotFoundError:
        return []

# Đoạn mã hiện tại của bạn để lấy dữ liệu 19017688
start = 19000001
end   = 19017688
url = "https://diemthi.tuyensinh247.com/tsHighSchool/ajaxDiemthiThpt"

def fetch_data(start, end):
    for i in range(start, end + 1):
        payload = {"sbd": str(i)}  
        try:
            r = requests.post(url, data=payload)  
            r.raise_for_status()  
            response_data = r.json() 
            if response_data['success']:  
                insert_data(response_data['data'])  
            else:
                print(f"No data found for SBD {i}")
                log_failed_sbd(i)  
        except requests.exceptions.RequestException as e:
            print(f"Request failed for SBD {i}: {e}")
            log_failed_sbd(i)  
        except (ValueError, KeyError) as e:
            print(f"Invalid response for SBD {i}: {e}")
            log_failed_sbd(i) 

# Thử lại các số báo danh bị lỗi
def retry_failed_sbd():
    failed_sbds = read_failed_sbd()
    for sbd in failed_sbds:
        payload = {"sbd": sbd}
        try:
            r = requests.post(url, data=payload)
            r.raise_for_status()
            response_data = r.json()
            if response_data['success']:
                insert_data(response_data['data'])
                print(f"Successfully retried SBD {sbd}")
            else:
                print(f"No data found for retried SBD {sbd}")
        except requests.exceptions.RequestException as e:
            print(f"Retry request failed for SBD {sbd}: {e}")
        except (ValueError, KeyError) as e:
            print(f"Invalid response for retried SBD {sbd}: {e}")

# Lấy dữ liệu lần đầu
fetch_data(start, end)

# Đợi 5 phút trước khi thử lại các số báo danh bị lỗi
time.sleep(300)

# Thử lại các số báo danh bị lỗi
retry_failed_sbd()
