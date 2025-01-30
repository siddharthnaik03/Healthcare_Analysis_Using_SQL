create database if not exists  healthcareDB;
USE healthcareDB;

CREATE TABLE Patients (
    PatientID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Age INT NOT NULL,
    Gender VARCHAR(10) NOT NULL,
    Address VARCHAR(255)
);

-- Create the Hospitals table
CREATE TABLE Hospitals (
    HospitalID INT AUTO_INCREMENT PRIMARY KEY,
    HospitalName VARCHAR(100) NOT NULL,
    Location VARCHAR(100) NOT NULL,
    Capacity INT NOT NULL
);

-- Create the Admissions table
CREATE TABLE Admissions (
    AdmissionID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT,
    HospitalID INT,
    AdmissionDate DATE NOT NULL,
    DischargeDate DATE,
    ReasonForAdmission VARCHAR(255),
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (HospitalID) REFERENCES Hospitals(HospitalID)
);

-- Create the Treatments table
CREATE TABLE Treatments (
    TreatmentID INT AUTO_INCREMENT PRIMARY KEY,
    AdmissionID INT,
    ProcedureName VARCHAR(100) NOT NULL,
    Cost DECIMAL(10, 2) NOT NULL,
    Outcome VARCHAR(50),
    FOREIGN KEY (AdmissionID) REFERENCES Admissions(AdmissionID)
);

-- Insert data into Patients table
INSERT INTO Patients (FullName, Age, Gender, Address) VALUES
('John Doe', 45, 'Male', '123 Elm Street'),
('Jane Smith', 34, 'Female', '456 Oak Avenue'),
('Sam Brown', 29, 'Male', '789 Pine Road'),
('Lisa White', 52, 'Female', '321 Maple Lane'),
('Tom Green', 67, 'Male', '654 Birch Blvd'),
('Alice Johnson', 40, 'Female', '987 Willow Court'),
('Robert Black', 60, 'Male', '564 Cypress Road'),
('Emily Davis', 25, 'Female', '321 Cedar Avenue'),
('Michael Scott', 50, 'Male', '742 Birch Lane'),
('Sarah Taylor', 33, 'Female', '159 Spruce Drive');

-- Insert data into Hospitals table
INSERT INTO Hospitals (HospitalName, Location, Capacity) VALUES
('General Hospital', 'New York', 500),
('City Clinic', 'Los Angeles', 200),
('Central Medical Center', 'Chicago', 300),
('Regional Health Facility', 'Houston', 150),
('Sunrise Hospital', 'Phoenix', 400);

-- Insert data into Admissions table
INSERT INTO Admissions (PatientID, HospitalID, AdmissionDate, DischargeDate, ReasonForAdmission) VALUES
(1, 1, '2024-11-01', '2024-11-05', 'Surgery'),
(2, 2, '2024-11-03', '2024-11-08', 'Therapy'),
(3, 3, '2024-11-10', '2024-11-15', 'Accident'),
(4, 4, '2024-11-12', '2024-11-19', 'Routine Checkup'),
(5, 5, '2024-12-01', '2024-12-08', 'Infection'),
(6, 1, '2024-12-01', NULL, 'Surgery'),
(7, 2, '2024-12-02', '2024-12-05', 'Fracture Repair'),
(8, 3, '2024-12-03', NULL, 'Chronic Illness'),
(9, 4, '2024-12-03', '2024-12-18', 'Therapy'),
(10, 5, '2024-12-04', '2024-12-18', 'Infection');

-- Insert data into Treatments table
INSERT INTO Treatments (AdmissionID, ProcedureName, Cost, Outcome) VALUES
(1, 'Appendectomy', 1500.00, 'Successful'),
(2, 'Physical Therapy', 800.00, 'Ongoing'),
(3, 'Fracture Repair', 3000.00, 'Successful'),
(4, 'Blood Test', 200.00, 'Pending'),
(5, 'Antibiotics', 500.00, 'Improved'),
(6, 'Gallbladder Surgery', 4000.00, 'Successful'),
(7, 'X-Ray', 300.00, 'Successful'),
(8, 'Chemotherapy', 5000.00, 'Ongoing'),
(9, 'MRI Scan', 1200.00, 'Pending'),
(10, 'Diabetes Treatment', 700.00, 'Improved');


-- 1.Patient Demographics: Retrieve the number of patients grouped by gender and calculate the average age of patients.
select Gender,avg(Age)as average_age,count(PatientID)as Counts from Patients group by Gender;


-- 2.  Hospital Utilization: Identify hospitals with the highest number of admissions.
select h.HospitalName,Count(a.AdmissionID)as NumberOf_Admission from admissions a join hospitals h on a.HospitalID=h.HospitalID group by h.HospitalName order by Count(a.AdmissionID) desc limit 1;


-- 3.Treatment Costs: Calculate the total cost of treatments provided at each hospital.
select sum(t.Cost)as TotalCost,h.HospitalName from treatments t join admissions a on a.AdmissionID=t.AdmissionID join hospitals h on h.HospitalID=a.HospitalID group by h.HospitalName;


-- 4.Length of Stay Analysis: Extract the average length of stay for patients grouped by hospital.
select round(avg(datediff(a.DischargeDate,a.AdmissionDate)),0) as AvgStay, h.HospitalName from admissions a join hospitals h on a.HospitalID=h.HospitalID group by h.HospitalName;


-- 5.List all patients who stayed longer than 7 days in any hospital.
SELECT P.FullName, A.HospitalID, DATEDIFF(A.DischargeDate, A.AdmissionDate) ASLengthOfStay FROM Admissions A JOIN Patients P ON A.PatientID = P.PatientID WHERE DATEDIFF(A.DischargeDate, A.AdmissionDate) > 7;



-- 6.Identify treatments that have been performed more than 5 times across all hospitals.
SELECT T.ProcedureName, COUNT(T.TreatmentID) AS TreatmentCount
FROM Treatments T
GROUP BY T.ProcedureName
HAVING COUNT(T.TreatmentID) >5;


-- 7. Combine admission and treatment data to display complete patient histories.
SELECT P.FullName, A.AdmissionDate, A.DischargeDate, A.ReasonForAdmission,
T.ProcedureName, T.Cost, T.Outcome
FROM Patients P
JOIN Admissions A ON P.PatientID = A.PatientID
JOIN Treatments T ON A.AdmissionID = T.AdmissionID
ORDER BY P.FullName, A.AdmissionDate;


-- 8. Combine lists of patients admitted for different reasons (e.g., surgery and therapy
select p.FullName,a.ReasonForAdmission from patients p join admissions a on a.PatientID=p.PatientID where ReasonForAdmission in('surgery','therapy');


-- 9. find the hospital with the highest average treatment cos
select h.HospitalName from hospitals h where h.HospitalID= (select a.HospitalID from admissions a join treatments t on a.AdmissionID=t.AdmissionID group by a.HospitalID order by avg(t.Cost) desc limit 1 );


-- 10.Create a view named HospitalPerformance to display the total number of admissions,average length of stay, and total revenue generated for each hospital.
 Create View HospitalPerformance AS select h.HospitalName, Count(a.AdmissionID)as No_Of_Admissions,round(avg(day(a.DischargeDate)-day(a.AdmissionDate)),0) as AVg_Stay_Days,sum(t.Cost)as Total_revenue from treatments t join admissions a on a.AdmissionID=t.AdmissionID join hospitals h on h.HospitalID=a.HospitalID group by h.HospitalName;


-- 11.rank hospitals based on their total revenue.
Select HospitalName,Total_revenue, rank() over ( order by Total_revenue DESC)as ranking from hospitalperformance;


-- 12.Use DENSE_RANK to rank treatments based on their frequency.
select count(TreatmentID),ProcedureName ,dense_rank() over(partition by ProcedureName order by count(TreatmentID)Desc)from treatments group by ProcedureName;




