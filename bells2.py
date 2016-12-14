### IMPORTS ###################################################

from stravalib import Client
import logging
import time
import serial
import struct
import random
import socket

### LOGGING AND SERIAL SETUP ###################################################

logging.basicConfig(level=logging.WARNING,
                    format='%(asctime)s %(levelname)s %(message)s',
                    filename='stravaExploration.log',
                    filemode='w')
logging.debug('A debug message')
#logging.info('Some information')
logging.warning('A shot across the bows')

### SOCKET #########################################################################

s = socket.socket()         # Create a socket object
host = socket.gethostname() # Get local machine name
port = 5000                # Reserve a port for your service.

s.connect((host, port))
time.sleep(2)
s.send(b"Strava Bells says what up!")


### API KEYS AND SHIT ###################################################

### eventually get this to work w/ other athelete's activities 

STRAVA_ACCESS_TOKEN = 'xxxxxxxxxxxx'  ## i think this is just the public facing API so I can only use my own stuff
client = Client(access_token=STRAVA_ACCESS_TOKEN)
athleteID = [1818295] #1818295



### FUNCTIONS ###################################################

def getSpeeds(cIDs):

	### still not using the athlete ID

	allaIDS = []
	activities = client.get_activities(limit=100)
	
	for i in activities:
		if i.manual == False:
			allaIDS.append(i.id)

	aIDs = random.sample(allaIDS,4)
	
	streamsDicts = []
	streamsFinal = []

	for i in aIDs:
		types = ['velocity_smooth']
		streams = client.get_activity_streams(i, types=types, resolution='low')
		activity = client.get_activity(i)	
		if 'velocity_smooth' in streams.keys():
			actName = activity.name 
			raw = streams['velocity_smooth'].data
			streamsDicts.append({actName:raw[1:]})	
		else: 
			print("velocity_smooth is not available")
	
	### possible to do this w/ list comprehension? 
	for i in streamsDicts:
		for key, value in i.items():
			value = [round((x * 3600) / 1000,0) for x in value]
			streamsFinal.append({key:value})
			
	printInterval(streamsFinal)



def printInterval(streamsFinal):
	#print streamsFinal
	speedComapre = [] ### this needs to be extended for more than 2
	titles = []
	dingMin = 30 #km per hour

	for i in streamsFinal:
		#print(i)
		for key, value in i.items():
			#print(key)
			#print(value)
			titles.append(key)
			speedComapre.append(value)
	print("{0} == {1} == {2} == {3}".format(titles[0],titles[1],titles[2],titles[3]))
	#print(titles)
	s.send(b"titlesStart")
	time.sleep(1)
	sendTitles = str("{0} == {1} == {2} == {3}".format(titles[0],titles[1],titles[2],titles[3])).encode()
	#s.send(sendTitles)
	#time.sleep(5)
	#for x in titles:
	#	title = str("=== {} ===".format(x)).encode()
	#	#print("=== {} ===".format(x))
	#	time.sleep(1)
	s.send(b"titlesEnd")

	finalSpeeds = zip(*speedComapre)  ### http://stackoverflow.com/questions/4112265/how-to-zip-lists-in-a-list
	time.sleep(1)

	for i in finalSpeeds:
		print(i)
		for x in i:
			if x >= dingMin:
				print("{}-{}".format(i.index(x),int(x)))
				pin = str(i.index(x)).encode()  # will either be a 0, 1, 2, 3...etc.
				#ser.write(struct.pack('>B', pin))
				#toSend = bytes(pin)
				s.send(pin)
				print("!end: {0}".format(pin))
				time.sleep(1)
	s.send(b"exitrn")		

### CALL IT ###################################################

getSpeeds(athleteID)
