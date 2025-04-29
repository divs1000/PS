# Frequency Estimation and Monitoring

This repository contains MATLAB and Python scripts for frequency estimation and a real-time monitoring application.

## MATLAB Files

### 1. amplitude_change.m
- Simulates signal with amplitude step changes
- Features:
  - 15% amplitude step change at 0.15s
  - Sliding window least-squares estimation
  - Window sizes: 10ms and 20ms

### 2. bath_tub.m
- Implements "bath-tub" frequency profile
- Features:
  - Time-varying frequency profile
  - Multiple harmonics (1st, 5th, 7th, 11th, 13th)
  - Sliding-window NLS estimation

### 3. frequency_step.m
- Analyzes frequency step changes
- Features:
  - Step change from 49Hz to 51Hz
  - Sliding window estimation
  - Window sizes: 10ms and 20ms

### 4. harmonics.m
- Analyzes harmonic impact on estimation
- Features:
  - Harmonic content up to 7th and 13th
  - Sliding-window NLS estimation
  - Model comparison

## Python Files

### 1. fibbonacci.py
- Optimized Fibonacci search algorithm
- Features:
  - Modified Fibonacci search
  - Function evaluation counter
  - Search range: 48.5Hz to 51.5Hz

## Simulink Models
- `HarmonicNLS_APF_Model.slx`: Harmonic analysis with NLS
- `Simulink_NLS.slx`: General NLS estimation

## Application

### System Architecture
- Host: Simulink model (`app.final.slx`) for frequency estimation
- Client: Web interface with MongoDB for data storage

### Features
- Real-time estimated frequency monitoring
- Frequency vs time plot
- Tabular data display
- UDP data transmission
- MongoDB storage
- Historical data access
- Data export

### Running the App
1. Extract `app.zip`
2. Install and start MongoDB:
   - Run `mongod` in Command Prompt
3. Install required npm packages:
   - Navigate to app directory
   - Run `npm install`
4. Run UDP sender:
   - Run `udp_send_to_mongo.py`
5. Start the server:
   - Run `node server.js`
6. Run Simulink model:
   - Open `app.final.slx`
   - Configure UDP settings
   - Start simulation
7. Access web interface:
   - Open `http://localhost:4000`
   - View frequency data

## Requirements
- MATLAB R2019b+
- Python 3.6+
- Simulink
- MongoDB
- Node.js and npm
- Web browser

## Notes
- Sampling frequency: 1600 Hz
- Frequency range: 48.5-51.5 Hz
- UDP for real-time communication
- MongoDB for data storage 