# DiaCare - Personalized Diabetes Reminder System

DiaCare is a mobile-based diabetes management application designed to support diabetic patients and doctors through reminders, diet guidance, fruit sugar content information, chatbot assistance, and real-time health data access.

The system focuses on providing a simple, localized, and user-friendly digital healthcare solution for diabetic patients, especially in Sri Lanka.


## Project Overview

Diabetes management requires continuous attention to medication, diet control, and regular communication with healthcare professionals. Many patients still depend on manual notebooks, memory-based medication tracking, and disconnected digital tools.

DiaCare provides a unified mobile platform where patients can manage daily diabetes-related activities while doctors can monitor patient health records and glucose trends more effectively.

## Main Features

### Patient Features

- Patient registration and login
- Patient dashboard
- Medication reminder scheduling
- Diet plan guidance
- Fruit sugar content information per 100g
- Chatbot support for basic diabetes-related guidance
- Simple and user-friendly mobile interface

### Doctor Features

- Doctor registration and login
- Doctor dashboard
- View patient profiles
- Support better doctor-patient communication through real-time data access

## Problem Addressed

Diabetic patients in Sri Lanka often face difficulties such as:

- Forgetting medication schedules
- Poor diet control
- Lack of water intake monitoring
- Limited communication between patients and doctors
- Lack of localized diabetes management applications
- Difficulty for doctors to monitor patient progress between clinic visits

DiaCare addresses these issues by combining reminders, diet management, chatbot support, and doctor monitoring in one application.


## Technologies Used

- **Flutter** - Mobile application development
- **Dart** - Programming language
- **Firebase Authentication** - Secure user login and registration
- **Cloud Firestore** - Real-time cloud database
- **Firebase Cloud Storage** - Image and file storage
- **Flutter Local Notifications** - Reminder notifications
- **Figma** - UI/UX design and prototyping
- **Android Studio** - Development environment

## System Modules

### 1. Authentication Module

The application supports secure login and registration for both patients and doctors. Users are redirected to separate dashboards based on their role.

### 2. Patient Dashboard

The patient dashboard allows users to manage glucose readings, reminders, diet plans, and fruit sugar information.

### 3. Doctor Dashboard

The doctor dashboard allowa patients details and patients ,medical reports.

### 4. Reminder Module

Patients can schedule medication reminders to improve daily diabetes management.

### 5. Diet Management Module

The system provides diabetes-friendly diet guidance, including food categories suitable for diabetic patients.

### 6. Fruit Sugar Content Module

The application provides sugar content information for fruits per 100g to help patients make better food choices.

### 7. Chatbot Module

The chatbot provides basic diabetes-related guidance and answers frequently asked questions.


## System Architecture

DiaCare follows a cloud-based mobile application architecture.

- The mobile application is developed using Flutter.
- Firebase Authentication handles secure login.
- Superbase store patients reports
- Cloud Firestore stores patient records, glucose readings, diet data, and reminder information.
- Firebase Cloud Storage is used for storing images and related media.
- Doctors can access patient data through a role-based dashboard.
- Patients and doctors interact with the same cloud backend in real time.

## Functional Requirements

- Users can register and log in as patients or doctors.
- Patients can enter and store glucose readings.
- Patients can schedule medication  reminders.
- Patients can view diet and fruit sugar information.
- Doctors can view patient records.
- The system supports role-based access control.
- Data is stored securely in the cloud.


## Non-Functional Requirements

- Simple and easy-to-use interface
- Secure user authentication
- Role-based data access
- Real-time data synchronization
- Mobile-friendly Android interface
- Fast application loading time
- Scalable cloud-based backend
- Reliable data storage and backup support


## Development Methodology

This project follows the Agile development methodology. The system is developed in smaller phases or sprints, allowing each module to be designed, implemented, tested, and improved step by step.


## Current Implementation Status

The following modules have been implemented :

- User authentication
- Role-based dashboard navigation
- Patient and doctor login interfaces
- Cloud Firestore data storage
- Medication reminder scheduling
- Diet management interface
- Fruit sugar content display
- Basic chatbot functionality


## Future Improvements

Future improvements may include:

- Advanced AI-based chatbot responses
- More flexible reminder repetition options
- Missed medication tracking
- Predictive glucose level analysis
- Improved doctor analytics dashboard
- Automatic fruit image recognition
- UI improvements for elderly users
- iOS version support
- Advanced reports and export options


## Installation and Setup

### Prerequisites

Make sure the following are installed:

- Flutter SDK
- Dart SDK
- Android Studio
- Android Emulator or Android device
- Firebase project


## Testing

The application can be tested using:

- Android Emulator
- Physical Android device
- Firebase test data
- Functional testing
- Usability testing with selected users
- Reminder notification testing
- Role-based login testing


## Author

**Sewmi Patabendi**  
Plymouth Index Number: **10953503**  
Degree Program: **Computer Science**  
Module: **PUSL3190 Computing Project**

## Supervisor

**Mr. Gayan Perera**
