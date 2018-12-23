# Dependencies
from flask import Flask, jsonify

import pandas as pd
import numpy as np
import datetime as dt
import sqlalchemy
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import Session
from sqlalchemy import Column, Integer, String, Numeric, Text, Float
from sqlalchemy import create_engine, func, inspect


# database setup
engine1 = create_engine("sqlite:///hawaii.sqlite")

# Create conection to MySQL
session1 = Session(engine1)

# Flask setup
app = Flask(__name__)


#calculate dates for the query.
end_date = dt.datetime(year=2017, month=6, day=19)
start_date = end_date - dt.timedelta(days=365)

# query data set and build df
query = f"SELECT * FROM measurement WHERE date >= '{start_date}' AND date <= '{end_date}'"

df_query = pd.read_sql_query(query, session1.bind)

#df_query

# Flask Routes


@app.route("/api.v1.0/precipitation")
def precipitation():
    print("Server received request for 'Precipitation' page...")
    return "These are the dates and temperature observations from last year."
  
    # create replica of df_query to remove unwanted columns but leave the original df for other queries
    df_query_tobs = df_query

    # removed unwanted columns
    df_query_tobs.drop('id', axis=1, inplace=True)
    df_query_tobs.drop('station', axis=1, inplace=True)
    df_query_tobs.drop('prcp', axis=1, inplace=True)
    
    # Return the json representation dictionary. df to dictionary happening inside the argument of jsonify
    return jsonify(df_query_tobs.to_dict(orient='records'))


@app.route("/api/v1.0/stations")
def stations():
    print("Server received request for 'stations' page...")
    return "These are the list of stations that recorded dates and temperature observations from last year."
  
    query = f"SELECT DISTINCT station FROM measurement WHERE date >= '{start_date}' AND date <= '{end_date}'"
    
    # build df from query result
    df_query = pd.read_sql_query(query, session1.bind)
    
    # Return the json representation dictionary. df to dictionary happening inside the argument of jsonify
    return jsonify(df_query.to_dict(orient='records'))

@app.route("/api/v1.0/tobs")
def tobs():
    print("Server received request for 'Temperature Observations' page...")
    return "This is the list of Temperature Observations (tobs) from previous year!"
    
    #calculate the dates for previous year for the query.
    start_date2 = start_date - dt.timedelta(days=365)
    end_date2 = end_date - dt.timedelta(days=365)
    
    query = f"SELECT tobs FROM measurement WHERE date >= '{start_date2}' AND date <= '{end_date2}'"
    
    # build df from query result
    df_query = pd.read_sql_query(query, session1.bind)
    
    return jsonify(df_query.to_dict(orient='records'))

@app.route("/api/v1.0/<start>")
def tobs_start():
    print("Server received request for 'Minimum Temperature, Average Temperature, Maximum Temperature of a given start' page...")
    return "Here is the list of Temperature information for the given date!"
    
    query = f"SELECT MIN(tobs), MAX(tobs), AVG(tobs) FROM measurement WHERE date >= '{start_date}'"
    
    # build df from query result
    df_query = pd.read_sql_query(query, session1.bind)

    my_list = df_query["MIN(tobs)"].values
    min_tobs = my_list[0]

    my_list = df_query["MAX(tobs)"].values
    max_tobs = my_list[0]

    my_list = df_query["AVG(tobs)"].values
    avg_tobs = my_list[0]
    
    return jsonify(min_tobs, max_tobs, avg_tobs)

@app.route("/api/v1.0/<start>/<end>")
def tobs_given_range():
    
    print("Server received request for 'Minimum Temperature, Average Temperature, Maximum Temperature of a given start or date range' page...")
    return "Here is the list of Temperature information for the given date range!"
    
    query = f"SELECT MIN(tobs) FROM measurement WHERE date >= '{start_date}' AND date <= '{end_date}'"
    
    # build df from query result
    df_query = pd.read_sql_query(query, session1.bind)

    my_list = df_query["MIN(tobs)"].values
    min_tobs = my_list[0]

    my_list = df_query["MAX(tobs)"].values
    max_tobs = my_list[0]

    my_list = df_query["AVG(tobs)"].values
    avg_tobs = my_list[0]
    
    return jsonify(min_tobs, max_tobs, avg_tobs)


if __name__ == '__main__':
    app.run()