# Para instalar dependencias:
# pip install fastapi uvicorn boto3 pandas

# Para iniciar el servicio:
# uvicorn main:app --reload --host 0.0.0.0 --port 8000

from fastapi import FastAPI, HTTPException, UploadFile
from pydantic import BaseModel
import boto3
import pandas as pd
from io import BytesIO
from botocore.exceptions import NoCredentialsError, ClientError

app = FastAPI()

# Configuración de tu bucket
bucket_name = "scm-0112-so"
file_key = "data.csv" 

# Cliente S3
s3 = boto3.client("s3")


class Item(BaseModel):
    nombre: str = "Mateo"
    edad: int = 20
    altura: float = 183


@app.post("/insert/")
async def create_file(file: UploadFile):
    try:
        if not file.filename.endswith(".csv"):
            raise HTTPException(status_code=400, detail="El archivo debe ser un CSV")

        file_content = await file.read()

       
        s3.put_object(Bucket=bucket_name, Key=file_key, Body=file_content)

        return {"message": "Archivo CSV guardado correctamente en S3"}

    except NoCredentialsError:
        raise HTTPException(status_code=500, detail="No se encontraron credenciales de AWS")
    except ClientError as e:
        raise HTTPException(status_code=500, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")



@app.get("/count")
def count_rows():
    try:
       
        response = s3.get_object(Bucket=bucket_name, Key=file_key)
        data = response["Body"].read()

        
        df = pd.read_csv(BytesIO(data))
        num_rows = len(df)

        return {"rows": num_rows}

    except s3.exceptions.NoSuchKey:
        raise HTTPException(status_code=404, detail="No existe el archivo CSV en el bucket")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
