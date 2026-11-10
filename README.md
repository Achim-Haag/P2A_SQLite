# Powershell 5.1 and SQLite3 Database

	P2A_Add_Airport.ps1 by Achim Haag
	
	--- Problem ---
		Pilot2ATC Version 3 Database filled with Navigraph Data doesn't contain all airports available in MSFS 2020,
		e.g. Chinese Airport ZGWZ Wuzhou (for checkerboard approach to VHHX Kai Tak ;-)
		
	--- Solution ---
		Extract data of missing airports from runways.xml created by Peter Dowson's fine utility Makerwys
		
	--- Requirements ---
		- Powershell Version 5.1
		- Pilot2ATC Version 3.0.0.0 RC4 SQLite-Database P2ADynamicData.db (https://www.pilot2atc.com/index.php/v3-downloads)
		- runways.xml as output file from Makerwys 5.132 (https://fsuipc.com/downloadspage/)
		- MSFS 2020 as of September 2026
		- PSSqlite
			* Installed once by Powershell-Command "Install-Module -Name PSSQLite" from Powershell Gallery
			  If "Get-PSRepository" returns "PSGallery Untrusted https://www.powershellgallery.com/api/v2",
			  the Install-Module command should find and download it.
			* Only for info: https://www.powershellgallery.com/packages/PSSQLite/1.1.0
			* Source and explicit download (although I couldn't find out what):
			  Github: https://github.com/RamblingCookieMonster/PSSQLite/tree/master/PSSQLite
			* After "Install-Module", PSSQlite will be imported automatically if installed
			  but this script does an Import-Module to check its existence

	--- Directory Structure ---
		- Create the following structure in 
		- Folder . with this script ($PSScriptRoot)
			- Folder .\data
			- File .\data\P2ADynamicData.db (SQLite Database)
				Copy the file from your P2A data folder for processing,
				afterwards copy it back (after a backup of the original file has been taken !!!)
			- Folder .\MSFS2020_Makerwys
			- File .\MSFS2020_Makerwys\runways.xml (output from Makerwys.exe Version 5.132)
				Copy the file from the folder where Makerwys.exe put its output files
				No need to copy it back as this file will not be modified
			
	--- Parametes ---
		- One or more ICAO IDs separated by space
		- Optional last parameter "bkupdone" avoid "Backup P2A DB" question
		- Optional last parameter "debug" for additional messages

	--- Start this script ---
		- In a Powershell: .\P2A_Add_Airport.ps1 <icao1> [ <icao2> ... ]
		- in a Command Prompt: powershell -command C:\...\P2A_Add_Airport.ps1 <icao1> [ <icao2> ... ]
		
	--- Example in Powershell for ZGWZ Wuzhou Changzhoudao Airport ---
	
		1. Open Powershell and check version is 5.1 (default in Win 10 22H2):
			> echo $PSVersiontable
				Name                           Value
				----                           -----
				PSVersion                      5.1.19041.7725

		2. Download MakeRwys 5.132 from https://fsuipc.com/downloadspage/
			a. Extract the MakeRwys.zip and copy the contents of the extracted folder to a folder outsite any sim
				e.g. C:\Games\MSFS2020_Makerwys
			b.	Run MakeRwys.exe, it should find your MSFS installation and generate the files,
				at least Runways.xml should have been created and contain information about the airport (e.g. ZGWZ)
			
		3. Check the location your Pilot2ATC V3 Database file:
			C:\...\Pilot2ATC_3_x64\Data\P2ADynamicData.db
			
		4. Create Folder and Subfolders somewhere
			In this example, I use E:\work\P2A_AddAP
			I use a non-admin Powershell, it could be done by Windows Explorer either
			> E:
			> cd \
			> mkdir \work\P2A_AddAP
			> mkdir \work\P2A_AddAP\Data
			> mkdir \work\P2A_AddAP\MSFS2020_Makerwys
			
		5. Copy the necessary files using Windows Explorer
			- P2A_Add_Airport.ps1 -> E:\work\P2A_AddAP\
			- C:\...\Pilot2ATC_3_x64\Data\P2ADynamicData.db -> E:\work\P2A_AddAP\Data
			- C:\Games\MSFS2020_Makerwys\Runways.xml -> E:\work\P2A_AddAP\MSFS2020_Makerwys

		6. The script needs a module to access the P2A SQLite3 database,
			it has to be installed once, manually, in an Administrator Powershell session
			and from Source 'PSGallery'
			
			> Install-Module -Name PSSQLite
				Untrusted repository
				You are installing the modules from an untrusted repository...
				Are you sure you want to install the modules from 'PSGallery'?	
				-> Y
			> Get-PSRepository
				Name                      InstallationPolicy   SourceLocation
				----                      ------------------   --------------
				PSGallery                 Untrusted            https://www.powershellgallery.com/api/v2
			> Get-InstalledModule
				Version    Name                                Repository           Description
				-------    ----                                ----------           -----------
				1.1.0      PSSQLite                            PSGallery            Query SQLite databases
				...
			> exit

		The above steps 1...6 have to be done once,
		The following steps have to be done each time you add an ICAO ID.

		7. Run the script in a non-Admin Powershell.
			It works only in the created P2A_AddAP folder, nothing is changed in Pilot2ATC
			> E:
			> cd \work\P2A_AddAP
			> .\P2A_Add_Airport.ps1 zgwz
				10.11.26 03:37:53 === P2A_Add_Airport.ps1 V0.9 init ===
				10.11.26 03:37:53 Backup exists for file E:\work\P2A_AddAP\data\P2ADynamicData.db ?
				??? Please answer Y or N : n
			Enter	-> Y (if running outside your real P2A folder as done in this example)
			Enter	-> N (if running against your P2A Data folder)
			or use last parameter "bkupdone" to avoid this question at all
				...
				10.11.26 03:16:53 ZGWZ Airport Name is empty, please tell it or just press ENTER key
				??? Airport Name (or ENTER key for none) : 
			Enter	-> Wuzhou Changzhoudao
				10.11.26 03:16:53 ZGWZ Airport City is empty, please tell it or just press ENTER key
				??? Airport City (or ENTER key for none) : Wuzhou Changzhoudao
			Enter	-> Wuzhou
				10.11.26 03:27:18 Inserting these airport data in P2A DB airports
				ICAO:           [ZGWZ]
				Name:           [WUZHOU CHANGZHOUDAO]
				City:           [Wuzhou]
				Latitude:       [23.456654]
				Elevation:      [86.66]
				MagVar:         [0.000]
				TransAlt:       [0]
				??? Add ICAO ID ZGWZ to DB airports ? Please answer Y or N :				
			Enter	-> Y
				...
				10.11.26 03:48:04 Read back DB airport table airports for ICAO ID ZGWZ
				Id                 : 17159
				Name               : WUZHOU CHANGZHOUDAO
				ICAO_Code          : ZGWZ
				...
				10.11.26 03:28:53 --- Processing runway  RW18  for ICAO ID ZGWZ ---
				Runway RW18 for Airport DB-ID 17159
						Elevation 86.66, Length 5892, Width 235.68, Heading: 179.999
						PatternAltitude 305, Takeoff enabled = 1, Landing enabled = 1
						Pos Lat: 23.464727, Pos Long 111.248138 Type 1
				10.11.26 03:48:04 Read back DB runway table runways for Airport DB-ID 17159
				Id                    : 42531
				Name                  : RW18
				...
				10.11.26 03:28:53 --- Processing runway  RW36  for ICAO ID ZGWZ ---
				Runway RW18 for Airport DB-ID 17159
					Elevation 86.66, Length 5892, Width 235.68, Heading: 179.999
					PatternAltitude 305, Takeoff enabled = 1, Landing enabled = 1
					Pos Lat: 23.464727, Pos Long 111.248138 Type 1
				10.11.26 03:48:04 Read back DB runway table runways for Airport DB-ID 17159
					Id                    : 42531
					Name                  : RW18
				...
				10.11.26 03:28:53 === List of successfully processed airports and their runways, each with DB-ID ===
				->   ZGWZ[17159] RW18[42531] RW36[42532]
				10.11.26 03:28:53 === P2A_Add_Airport.ps1 V0.9 ended ===
				
		8. Backup original P2A V3 file Data\P2ADynamicData.db
			Then copy the above modified P2ADynamicData.db to the original P2A V3 folder
			
		9. Start Pilot2ATC V3 RC4
			Enter ZGWZ in a flight plan or import flight plan containing airport ZGWZ, it should work now
			Locate ZGWZ in the map on the left side, there should be an airport symbol
	
	--- File structure and SQLITE3 Database structure ---

	Structure of runways.xml:
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

	Accessed SQLite database tables (output of .schema command)

	Structure of SQLite DB P2ADynamicData.db, Table airports:
		CREATE TABLE [Airports] (
			[Id]    integer PRIMARY KEY AUTOINCREMENT NOT NULL,
			[Name]  nvarchar COLLATE NOCASE,
			[ICAO_Code]     nvarchar COLLATE NOCASE,
			[Elevation]     real,
			[MagVar]        real,
			[Position_Latitude]     real,
			[Position_Longitude]    real,
			[CountryCode]   char(2) COLLATE NOCASE,
			[Country]       nvarchar COLLATE NOCASE,
			[City]  nvarchar COLLATE NOCASE,
			[State] nvarchar COLLATE NOCASE,
			[UserModified]  bit,
			[TransitionAltitude]    integer
		);

	Structure of SQLite DB P2ADynamicData.db, Table runways:
		CREATE TABLE [Runways] (
			[Id]    integer PRIMARY KEY AUTOINCREMENT NOT NULL,
			[Name]  nvarchar COLLATE NOCASE,
			[Elevation]     real,
			[Length]        real,
			[Width] real,
			[SurfaceType]   integer,
			[Heading]       real,
			[PatternAltitude]       real,
			[Takeoff]       bit,
			[Landing]       bit,
			[Position_Latitude]     real,
			[Position_Longitude]    real,
			[PatternDirection]      nvarchar COLLATE NOCASE,
			[MidPosition_Latitude]  real,
			[MidPosition_Longitude] real,
			[Type]  integer,
			[UserModified]  bit,
			[Airport_Id]    integer NOT NULL,
				FOREIGN KEY ([Airport_Id])	REFERENCES [Airports]([Id])
		);
		CREATE INDEX [Runways_IX_FK_AirportRunway]
			ON [Runways]	([Airport_Id] DESC);
		
	--- Modifications ---
		261001a	AH	- V0.9 Initial Version
		261110a	AH	- V1.0 Example and Corrections. Tested in live environment MSFS 2020 / P2A V3 RC4