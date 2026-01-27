FROM python:3.10-slim

WORKDIR /img_fol

COPY . .

COPY ["database_generator", "/img_fol/database"]

CMD ["python", "script.py"]

































FROM python:3.9-slim


WORKDIR /fol_2_2

ENV USER="Sadio Mane"

COPY file.py .

RUN apt-get update && apt-get install -y \
    htop \
    sudo \
    nano \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["python", "file.py"]

CMD ["Not-Normal"]




























FROM python:3.9-slim


WORKDIR /fol_2_3

COPY requirements.txt .

RUN echo -e "//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////"

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["python", "file.py"]







































# use the slim pythom image as a Foundation for our image
FROM python:3.10-slim

# create a './project/app' in the container
WORKDIR /project/app

# copy requirements.txt to the current directory
COPY requirements.txt .

# pip install is at the top of the file, ensuring this layer does not re-run whenever we rebuild the image
RUN pip install --no-cache-dir -r requirements.txt

# indicate that pandas has finished installing
RUN echo "Pandas package finished installing..."


ENV TARGET_ENV="PRODUCTION"

# copy everything in the current folder to './project/app/' in the container
COPY . .

# fire up the python script
CMD ["python", "processor.py"]









