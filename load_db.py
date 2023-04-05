import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import random
from datetime import datetime

cred = credentials.Certificate("key.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

#  "sensor2", "sensor3", "sensor4" 32
sensors = ["sensorOne"]
for sensor in sensors:
    for day in range(1, 2): 
        for hour in range(0, 24):
            fecha = datetime.strptime(f"2022-03-{day} {hour}:00:00".format(day=day, hour=hour), "%Y-%m-%d %H:%M:%S")
            print(fecha)
            sensor_data = {
                "humidity": round(random.uniform(0, 100), 2),
                "temperature": round(random.uniform(10, 40), 2),
                "pressure": round(random.uniform(900, 1100), 2),
                "altitude": round(random.uniform(0, 500), 2),
                "light": round(random.uniform(0, 100), 2),
                "soilMoisture": round(random.uniform(0, 100), 2),
                "rain": round(random.uniform(0, 10), 2),
                "battery": round(random.uniform(0, 100), 2),
                u'date': fecha,
                "id": sensor
            }
            print("date"+ f"2022-03-{day} {hour}:00:00")
            db.collection("Users/yuY2SQJgcOYgPUKvUdRx/measures").add(sensor_data)
