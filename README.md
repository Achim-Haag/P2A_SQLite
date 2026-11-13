# Powershell 5.1 and SQLite3 Database - Sample application

<!-- START doctoc -->
<!-- END doctoc -->

## Problem 

Pilot2ATC Version 3 Database filled with Navigraph Data doesn't contain all airports available in MSFS 2020,<br/>
e.g. Chinese Airport ZGWZ Wuzhou (for checkerboard approach to VHHX Kai Tak :sunglasses: ...um... :fearful:)

## Solution

Extract data of missing airports from runways.xml created by Peter Dowson's fine utility [Makerwys](https://fsuipc.com/downloadspage/)

## Requirements

- Powershell Version 5.1 (Windows 10 22H2)
- [Pilot2ATC](https://www.pilot2atc.com/index.php/v3-downloads) Version 3.0.0.0 RC4 SQLite-Database *P2ADynamicData.db*
- runways.xml as output file from [Makerwys 5.132](https://fsuipc.com/downloadspage/)
- [MSFS 2020](https://store.steampowered.com/app/1250410/Microsoft_Flight_Simulator_2020_40th_Anniversary_Edition/?l=german) as of September 2026
- PSSqlite
   - Installed once by Powershell-Command `Install-Module -Name PSSQLite` from [Powershell Gallery](https://www.powershellgallery.com/packages/PSSQLite/1.1.0)
   - If `Get-PSRepository` returns msg *`PSGallery Untrusted https://www.powershellgallery.com/api/v2`*,<br/>the Command `Install-Module` should be able to find and download the PSSQLite module.
   - Last resort: explicit download the module from the source website (although I couldn't find out what),<br/>see [Github RamblingCookieMonster: PSSQQlite](https://github.com/RamblingCookieMonster/PSSQLite/tree/master/PSSQLite)
   - After "Install-Module", PSSQlite will be imported automatically if correctly installed,<br/>but this script does an Import-Module by itself to check its existence

## Directory Structure

Create the following structure in a work folder with this script ($PSScriptRoot):
- ​Create Subfolder *.\data*
- Copy File *.\data\P2ADynamicData.db* (SQLite Database):
   - Copy the file from your P2A data folder for processing,
   - Afterwards copy it back to P2A (after a backup of the original file has been taken !!!)
- Create Subfolder *.\MSFS2020_Makerwys*
- Copy File *.\MSFS2020_Makerwys\runways.xml* (output from Makerwys.exe Version 5.132)
   - Copy the file from the folder where Makerwys.exe put its output files
   - No need to copy it back as this file will not be modified

## Parameter

- One or more __ICAO IDs__ separated by space
- Optional last parameter __*bkupdone*__ avoids *Backup P2A DB done?* question
- Optional last parameter __*debug*__ for additional messages (mutually exclusive to *bkupdone*)

## Start of script

Powershell:
```
PS> .\P2A_Add_Airport.ps1 icao1 [ <icao2> ... ] [ bkupdone|debug ]
```

In a Command Prompt:
```
> powershell -command C:\...\P2A_Add_Airport.ps1 icao1 [ <icao2> ... ] [ bkupdone|debug ]
```

## File structure and SQLITE3 Database structure

### Structure of runways.xml:

```xml
<?xml version="1.0" encoding="Windows-1252" ?>
	<data>
		<SimVersion>MSFS</SimVersion>	
		<ICAO id="ZGWZ">
			<ICAOName></ICAOName>
			...
			<Runway id="18">
				<Len>5892</Len>
				<Hdg>179.999</Hdg>
				...
			</Runway>
			<Runway id="36">
				<Len>5892</Len>
				<Hdg>359.999</Hdg>
			</Runway>
		</ICAO>
		<ICAO id="ZGXN">
			...
		</ICAO>
		...
	</data>
```

### Accessed SQLite database tables (output of .schema command)

#### Structure of SQLite DB P2ADynamicData.db, Table airports:

```
​CREATE TABLE [Airports] (
​	[Id]    integer PRIMARY KEY AUTOINCREMENT NOT NULL,
​	[Name]  nvarchar COLLATE NOCASE,
​	[ICAO_Code]     nvarchar COLLATE NOCASE,
​	[Elevation]     real,
​	[MagVar]        real,
​	[Position_Latitude]     real,
​	[Position_Longitude]    real,
​	[CountryCode]   char(2) COLLATE NOCASE,
​	[Country]       nvarchar COLLATE NOCASE,
​	[City]  nvarchar COLLATE NOCASE,
​	[State] nvarchar COLLATE NOCASE,
​	[UserModified]  bit,
​	[TransitionAltitude]    integer
);
```

#### Structure of SQLite DB P2ADynamicData.db, Table runways:

```
CREATE TABLE [Runways] (
​	[Id]    integer PRIMARY KEY AUTOINCREMENT NOT NULL,
​	[Name]  nvarchar COLLATE NOCASE,
​	[Elevation]     real,
​	[Length]        real,
​	[Width] real,
​	[SurfaceType]   integer,
​	[Heading]       real,
​	[PatternAltitude]       real,
​	[Takeoff]       bit,
​	[Landing]       bit,
​	[Position_Latitude]     real,
​	[Position_Longitude]    real,
​	[PatternDirection]      nvarchar COLLATE NOCASE,
​	[MidPosition_Latitude]  real,
​	[MidPosition_Longitude] real,
​	[Type]  integer,
​	[UserModified]  bit,
​	[Airport_Id]    integer NOT NULL,
​	​	FOREIGN KEY ([Airport_Id])	REFERENCES [Airports]([Id])
​);

CREATE INDEX [Runways_IX_FK_AirportRunway]
​	​	ON [Runways]	([Airport_Id] DESC);
```

# Example of script run for airport ZGWZ Wuzhou Changzhoudao

1. Open Powershell and check version is 5.1 (default in Win 10 22H2)
```
    > echo $PSVersiontable
​	​	Name                           Value
​	​	----                           -----
​	​	PSVersion                      5.1.19041.7725
```
   
2. Download MakeRwys 5.132 from https://fsuipc.com/downloadspage/
	- a. Extract the MakeRwys.zip and copy the contents of the extracted folder to a folder outsite any sim<br/>
		&nbsp;&nbsp;e.g. *C:\Games\MSFS2020_Makerwys*
	- b. Run MakeRwys.exe, it should find your MSFS installation and generate the files,<br/>
		&nbsp;&nbsp;at least Runways.xml should have been created and contain information about the airport (e.g. *ZGWZ*)
   
3. Check the location your Pilot2ATC V3 Database file:
   ​	*C:\...\Pilot2ATC_3_x64\Data\\__P2ADynamicData.db__*
   
4. Create Folder and Subfolders somewhere<br/>
   I created my work folder *E:\work\P2A_AddAP* for this example with a (non-admin) Powershell,<br/>
   it could be done by Windows Explorer either
```
   ​> E:
   > cd \
   > mkdir \work\P2A_AddAP
   > mkdir \work\P2A_AddAP\Data
   > mkdir \work\P2A_AddAP\MSFS2020_Makerwys
```
5. Copy the necessary files using Windows Explorer
   - __*P2A_Add_Airport.ps1*__  →  *E:\work\P2A_AddAP\\*
   - *C:\\...\Pilot2ATC_3_x64\Data\\__P2ADynamicData.db__*  →  *E:\work\P2A_AddAP\\__Data__*
   - *C:\Games\MSFS2020_Makerwys\\__Runways.xml__*  →  *E:\work\P2A_AddAP\\__MSFS2020_Makerwys__*

6. ​The script needs a module to access the P2A SQLite3 database,
   it has to be installed once, manually, in an __Administrator__ Powershell session
   and from Source __*PSGallery*__
```
   > Install-Module -Name PSSQLite
   ​	Untrusted repository
   ​	You are installing the modules from an untrusted repository...
   ​	Are you sure you want to install the modules from 'PSGallery'?
   ​	​	→ Y
   > Get-PSRepository
   ​	Name                      InstallationPolicy   SourceLocation
   ​	----                      ------------------   --------------
   ​	PSGallery                 Untrusted            https://www.powershellgallery.com/api/v2
   > Get-InstalledModule
   ​	Version    Name                                Repository           Description
   ​	-------    ----                                ----------           -----------
   ​	1.1.0      PSSQLite                            PSGallery            Query SQLite databases
   ​	...
   > exit
```

> [!NOTE]  
> The above steps have to be done once.<br/>
> The following steps have to be done each time you add an ICAO ID.

7. Run the script in a non-Admin Powershell.
It works only in the created P2A_AddAP folder, nothing is changed in Pilot2ATC
```
   > E:
   > cd \work\P2A_AddAP
   > .\P2A_Add_Airport.ps1 zgwz
		13.11.26 03:59:21 === P2A_Add_Airport.ps1 V1.1 init ===
		13.11.26 03:59:21 Backup exists for file C:\Users\Achim\Git_Repos_AH1\P2A_SQLite\data\P2ADynamicData.db ?
		??? Please answer Y or N :
	Enter	→ Y (if running outside your real P2A folder as done in this example)
	Enter	→ N (if running against your P2A Data folder)
	Or use last parameter "bkupdone" to avoid this question at all
		​...
		13.11.26 03:59:23 Processing 1 ICAO IDs
		13.11.26 03:59:23 === Loading C:\Users\Achim\Git_Repos_AH1\P2A_SQLite\msfs2020_Makerwys\runways.xml ===
		13.11.26 03:59:23 === Processing ICAO-ID [zgwz] ===
		...
​		13.11.26 03:59:24 --- Check for missing parameters of ICAO ID ZGWZ ---
		​13.11.26 03:59:24 ZGWZ Airport Name is empty, please tell it or just press ENTER key
​		??? Airport Name (or ENTER key for none) :
	Enter	→ Wuzhou Changzhoudao
​		13.11.26 03:59:24 ZGWZ Airport City is empty, please tell it or just press ENTER key
​		??? Airport City (or ENTER key for none) :
​	Enter	→ Wuzhou
​		13.11.26 03:59:39 Inserting these airport data in P2A DB airports
​		ICAO:           [ZGWZ]
​		Name:           [WUZHOU CHANGZHOUDAO]
​		City:           [Wuzhou]
​		Longitude:      [111.248138}
​		Latitude:       [23.456654]
​		Elevation:      [86.66]
​		MagVar:         [0.000]
​		TransAlt:       [0]
​		??? Add ICAO ID ZGWZ to DB airports ? Please answer Y or N : y
	Enter	→ Y
​		13.11.26 03:59:39 --- Add ICAO ID ZGWZ to database airports ---
​		13.11.26 03:59:40 Prepare DB INSERT for ICAO ID ZGWZ
​		13.11.26 03:59:40 Read back DB airport table airports for ICAO ID ZGWZ
​		Id                 : 17159
​		Name               : WUZHOU CHANGZHOUDAO
​		ICAO_Code          : ZGWZ
​	​	Elevation          : 86,66
​	​	MagVar             : 0
​	​	Position_Latitude  : 23,456654
​	​	Position_Longitude : 111,248138
​	​	CountryCode        :
​	​	Country            :
​	​	City               : Wuzhou
​	​	State              :
​	​	UserModified       :
​	​	TransitionAltitude : 0
​	​	13.11.26 03:59:40 Processing runways for Airport ZGWZ with DB-ID 17159
​	​	13.11.26 03:59:40 --- Processing runway  RW18  for ICAO ID ZGWZ ---
​	​	Runway RW18 for Airport DB-ID 17159
​	​	​	Elevation 86.66, Length 5892, Width 235.68, Heading: 179.999
​	​	​	PatternAltitude 305, Takeoff enabled = 1, Landing enabled = 1
​	​	​	Pos Lat: 23.464727, Pos Long 111.248138 Type 1
​	​	13.11.26 03:59:40 Read back DB runway table runways for Airport DB-ID 17159
​	​	Id                    : 42531
​	​	Name                  : RW18
​	​	Elevation             : 86,66
​	​	Length                : 5892
​	​	Width                 : 235,68
​	​	SurfaceType           :
​	​	Heading               : 179,999
​	​	...
​	​	Airport_Id            : 17159
​	​	13.11.26 03:59:40 --- Processing runway  RW36  for ICAO ID ZGWZ ---
​	​	Runway RW36 for Airport DB-ID 17159
​	​	​	Elevation 86.66, Length 5892, Width 235.68, Heading: 359.999
​	​	​	PatternAltitude 305, Takeoff enabled = 1, Landing enabled = 1
​	​	​	Pos Lat: 23.448565, Pos Long 111.248138 Type 1
​	​	13.11.26 03:59:40 Read back DB runway table runways for Airport DB-ID 17159
​	​	Id                    : 42532
​	​	Name                  : RW36
​	​	Elevation             : 86,66
​	​	Length                : 5892
​	​	Width                 : 235,68
​	​	SurfaceType           :
​	​	Heading               : 359,999
​	​	...
​	​	Airport_Id            : 17159
​	​	13.11.26 03:59:40 === List of successfully processed airports and their runways, each with DB-ID ===
​	​	->   ZGWZ[17159] RW18[42531] RW36[42532]
​	​	13.11.26 03:59:40 === P2A_Add_Airport.ps1 V1.1 ended ===
```
      
8. Backup __original__ P2A V3 file Data\*__P2ADynamicData.db__*<br/>
   Then copy the __above modified *P2ADynamicData.db* to the original P2A V3 folder__
   
9. Start Pilot2ATC V3 RC4<br/>
   Enter ZGWZ in a flight plan or import flight plan containing airport ZGWZ, it should work now.<br/>
   Locate ZGWZ in the map on the left side, there should be an airport symbol.

