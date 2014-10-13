# A simple weekly status report tracker

## Dependencies
* python 2.7+
* flask  >= 0.10
* flask-sqlalchemy >= 0.10

## Installation instructions
1. Ensure you have the python modules flask and flask-sqlalchemy installed
2. check out the repo
3. initialize the db using db.schema at root

  ```bash
  cat db.schema | sqlite3 src/reports.db
  ```
4. Run the server using main.py under src

  ```bash
  cd src; python ./main.py 
  ```
5. Access the tool via browser. Link will be displayed at the prompt.

  ```bash
  http://0.0.0.0:9887/
  ```
