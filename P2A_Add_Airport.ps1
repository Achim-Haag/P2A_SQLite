<#
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
#>

# ### Init ###
	$myver = "V1.0"			# Version of this script
	$myScrNm = $MyInvocation.MyCommand
	$mypath = Get-Location

# Initial startup message
	write-host " "
	$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
	write-host "$timestmp === $myScrNm $myver init ==="

#
	$mkrwxmlf = "runways.xml"								# runways.xml created by Peter Dowson FSUIPC - Makerwys
	$mkrwxmlp = "$mypath\msfs2020_Makerwys\$mkrwxmlf"		
	$p2adyndbf = "P2ADynamicData.db"					# P2A SQLite DB created by Dave's Pilot2ATC installation
	$p2adyndbfile = "$mypath\data\$p2adyndbf"			# P2A SQLite DB with fully qualified path
	$p2adyndbaptab = "airports"							# P2A SQLite Table airports
	$p2adyndbrwtab = "runways"							# P2A SQLite Table runways
	$p2adyndbrwidx = "Runways_IX_FK_AirportRunway"		# P2A SQLite Index Runways_IX_FK_AirportRunway on Table runways
	$procarraprw = New-Object System.Collections.ArrayList	# ArrayList of processed airports and their runways
#
	$PSSQLite = "PSSQLite"		# PSQLite Module
	
#
# Check input parameter for at least one ICAO ID (and optional "bkupdone" dummy ID)
#
	$parmnum = $args.count		# Number of given parameters in Script call
	
	$flgBkupdone = $false		# Init flag for asking/not asking about "Backup done"
	$flgDebug = $false			# Init flag for further debugging messages
#	
	if ( $parmnum -gt 0 ) {
		$lastpnbr = $parmnum - 1		# access last parameter
		$lasticao = $args[$lastpnbr]
		$lasticao = $lasticao.ToLower()	# in lowercase for compare
# If last parameter is "debug"
		if ( $args[$lastpnbr] -eq "debug" ) {	# Last parameter is "debug"
			$flgdebug = $true			# Set flag for not asking about "Backup done"
			$parmnum = $lastpnbr		# Don't process last parameter as it isn't an ICAO ID
		} else {
			if ( $args[$lastpnbr] -eq "bkupdone" ) {		# If last parameter is "bkupdone"		
				$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
				write-host "$timestmp Assume backup done for $p2adyndbfile"
				$flgBkupdone = $true		# Set flag for not asking about "Backup done"
				$parmnum = $lastpnbr		# Don't process last parameter as it isn't an ICAO ID
			} else {						# Last parameter isn't "bkpdone"
# If last parameter isn't "bkupdone" : Ask user if he had taken a backup before running this script
				$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
				write-host "$timestmp Backup exists for file $p2adyndbfile ?"
				$answer = Read-Host -prompt "??? Please answer Y or N "
				if ( $answer.ToLower() -eq "n" ) {
					$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
					write-host "$timestmp Please backup your P2A DB first -> exit 4"
					exit 4
				}
			}
		}
	}
	
# Check for remaining parameter (ICAO IDs)
	if ( $parmnum -le 0 ) {
		$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
		write-host "$timestmp Parameters: ICAO-ID1 [<ICAO-ID2 ... ICAO-IDx>]  [bkupdone]"
		write-host "$timestmp Parameter ICAO ID(s) missing -> exit 8"
		exit 8
	}
	$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
	write-host "$timestmp Processing $parmnum ICAO IDs"
	
#	
# Check if Powershell module PSSQLite by "RamblingCookieMonster" is available (meaning "Install-Module PSSQLite" was done before)
#
	if ( $flgdebug -eq $true ) { write-output "**DBG Importing Module $PSSQLite" }	# Debug-Message
	Import-Module $PSSQLite
	if ( -not $? ) {
		$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
		write-host "$timestmp Error in [Import-Module $PSSQLite], is it installed? -> exit 8"
		write-host "$timestmp Details see https://github.com/RamblingCookieMonster/PSSQLite"
		Get-InstalledModule
		exit 8
	}

#
# Check necessary files and set separate bits for each found file
#
	[byte]$filesfound = 0x00								# assume all files present, so set all bits zero
	
	if ( -not (Test-Path -pathtype leaf -path "$mkrwxmlp" ) ) {
		$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
		write-host "$timestmp Makerwys.exe output missing:"
		write-host "$timestmp Error in [Test-Path -pathtype leaf -path "$mkrwxmlp"]"
		$filesfound = $filesfound -bor 0x01			# Set bit 1 (rightmost) for missing makerwys file
	}
	if ( -not (Test-Path -pathtype leaf -path "$p2adyndbfile" ) ) {
		$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
		write-host "$timestmp Pilot2ATC V3 SQLite DB missing:"
		write-host "$timestmp Error in [Test-Path -pathtype leaf -path "$p2adyndbfile"]"
		$filesfound = $filesfound -bor 0x02			# Set bit 2 for missing makerwys file
	}
													# Check for any bit set (meaning some file is missing)
	if ( $filesfound -ne 0 ) {
		$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
		$answer = Read-Host -prompt "??? One or more files missing, shall I create them [Y/N]"
		if ( $answer.ToLower() -eq "y" ) {
			write-host " "
			$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
			write-host "$timestmp === Creating test files ==="
													# Create makerwys XML file with sample entry (ICAO ZGUO)
			if ( ($filesfound -band 0x01 ) -gt 0 ) {
					$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
					write-host "$timestmp Creating sample file $mkrwxmlp for airport ZGUO"
					$mkrwarr = @('<?xml version="1.0" encoding="Windows-1252" ?>',
								 '<data>','<SimVersion>MSFS</SimVersion>',
									'<ICAO id="ZGUO">',
										'<ICAOName>GUANGYUAN PANLONG AIRPORT</ICAOName>','<Country></Country>','<City>Guangyuan</City>',
										'<Longitude>116.881790</Longitude>','<Latitude>40.401134</Latitude>','<Altitude>314.39</Altitude>','<MagVar>0.000</MagVar>',
										'<Runway id="09">',
											'<Len>2618</Len>','<Hdg>82.715</Hdg>','<Lat>40.400677</Lat>','<Lon>116.877113</Lon>',
											'<ClosedLanding>FALSE</ClosedLanding>','<ClosedTakeoff>FALSE</ClosedTakeoff>','<PatternAltitude>305</PatternAltitude>',
										'</Runway>',
										'<Runway id="27">',
											'<Len>2618</Len>','<Hdg>262.715</Hdg>','<Lat>40.401585</Lat>','<Lon>116.886467</Lon>',
											'<ClosedLanding>FALSE</ClosedLanding>','<ClosedTakeoff>FALSE</ClosedTakeoff>','<PatternAltitude>305</PatternAltitude>',
										'</Runway>',
									'</ICAO>',
									
									
									'<ICAO id="ZGWZ">',
										'<ICAOName></ICAOName>','<Country></Country>','<City></City>',
										'<Longitude>111.248138</Longitude>','<Latitude>23.456654</Latitude>','<Altitude>86.66</Altitude>','<MagVar>0.000</MagVar>',
										'<Runway id="18">',
											'<Len>5892</Len>','<Hdg>179.999</Hdg>','<Lat>23.464727</Lat>','<Lon>111.248138</Lon>',
											'<ClosedLanding>FALSE</ClosedLanding>','<ClosedTakeoff>FALSE</ClosedTakeoff>','<PatternAltitude>305</PatternAltitude>',
										'</Runway>',
										'<Runway id="36">',
											'<Len>5892</Len>','<Hdg>359.999</Hdg>','<Lat>23.448565</Lat>','<Lon>111.248138</Lon>',
											'<ClosedLanding>FALSE</ClosedLanding>','<ClosedTakeoff>FALSE</ClosedTakeoff>','<PatternAltitude>305</PatternAltitude>',
										'</Runway>'
									'</ICAO>'
								'</data>')
													# Encoding ASCII as default is UTF16 with hidden leading bytes FF FE (visible in TotalCommander)
													# and later xml.load aborts with error "Hexadecimal value 0x00 is a invalid character"
					if ( $flgdebug -eq $true ) { write-output "**DBG Write file $mkrwxmlp" }	# Debug-Message
					$mkrwarr | Out-File $mkrwxmlp -encoding ASCII
					if ( -not $? ) {
						$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
						write-host ( "$timestmp Error writing array mkrwarr to Out-File " + $mkrwxmlp + '")] -> exit 8' )
						exit 8
					}
			} 
													# Create sample database
			if ( ($filesfound -band 0x02 ) -gt 0 ) {
													# Although not necessary, create empty file to test write permission into directory
					$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
					write-host "$timestmp Creating sample database $p2adyndbfile"
					New-Item -ItemType file $p2adyndbfile
					if ( -not $? ) {
						$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
						write-host ( "$timestmp Error creating empty file $p2adyndbfile -> exit 8" )
						exit 8
					}
													# Define table airports
					$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
					write-host "$timestmp Define database table $p2adyndbaptab"
					$dbcreateap = "CREATE TABLE $p2adyndbaptab (" +
									"Id integer PRIMARY KEY AUTOINCREMENT NOT NULL, " +
									"Name nvarchar COLLATE NOCASE, ICAO_Code nvarchar COLLATE NOCASE, " +
									"Elevation real, MagVar real, Position_Latitude real, Position_Longitude real, " +
									"CountryCode char(2) COLLATE NOCASE, Country nvarchar COLLATE NOCASE, City nvarchar COLLATE NOCASE, " +
									"State nvarchar COLLATE NOCASE, UserModified  bit, TransitionAltitude integer" +
									");"
					if ( $flgdebug -eq $true ) { write-output "**DBG SQLite on DB $p2adyndbfile" "**DBG Cmd: $dbcreateap" }	# Debug-Message
					Invoke-SqliteQuery -Query "$dbcreateap" -DataSource $p2adyndbfile
					if ( -not $? ) {
						$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
						write-host ( "$timestmp Error defining table $p2adyndbaptab -> exit 8" )
						exit 8
					}
													# Define table runways
					$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
					write-host "$timestmp Define database table $p2adyndbrwtab"
					$dbcreaterw = "CREATE TABLE [$p2adyndbrwtab] (" +
									"Id integer PRIMARY KEY AUTOINCREMENT NOT NULL, " +
									"Name nvarchar COLLATE NOCASE, Elevation real, Length real, Width real, " +
									"SurfaceType integer, Heading real, PatternAltitude real, Takeoff bit, Landing bit, " +
									"Position_Latitude real, Position_Longitude real, PatternDirection nvarchar COLLATE NOCASE, " +
									"MidPosition_Latitude real, MidPosition_Longitude real, Type integer, " +
									"UserModified bit, Airport_Id integer NOT NULL, " +
									"FOREIGN KEY (Airport_Id) REFERENCES Airports(Id) " +
									");"
					if ( $flgdebug -eq $true ) { write-output "**DBG SQLite on DB $p2adyndbfile" "**DBG Cmd: $dbcreaterw" }	# Debug-Message
					Invoke-SqliteQuery -Query "$dbcreaterw" -DataSource $p2adyndbfile
					if ( -not $? ) {
						$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
						write-host ( "$timestmp Error defining table $p2adyndbrwtab -> exit 8" )
						exit 8
					}
													# Define index into table runways
					$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
					write-host "$timestmp Define index $p2adyndbrwidx on table $p2adyndbrwtab"
					$dbcreateix = "CREATE INDEX $p2adyndbrwidx ON $p2adyndbrwtab (Airport_Id DESC);"
					if ( $flgdebug -eq $true ) { write-output "**DBG SQLite on DB $p2adyndbfile" "**DBG Cmd: $dbcreateix" }	# Debug-Message
					Invoke-SqliteQuery -Query "$dbcreateix" -DataSource $p2adyndbfile
					if ( -not $? ) {
						$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
						write-host ( "$timestmp Error defining index $p2adyndbrwidx -> exit 8" )
						exit 8
					}
			} 
		} else {
			write-host "$timestmp One or more files missing, please resolve this issue manually -> exit 8"
			exit 8
		}
	}

#
# Try to read runways.xml, use Load-method of empty XML-Object as it is much faster than Get-Content for big files
#
	write-host " "
	$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
	write-host "$timestmp === Loading $mkrwxmlp ==="

	$xmlAirports = [xml]''
	$xmlAirports.XmlResolver = $null
	$xmlAirports.Load("$mkrwxmlp")
	if ( -not $? ) {
		$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
		write-host ( "$timestmp Error in " + '[$xmlAirports.Load("' + $mkrwxmlp + '")] -> exit 8' )
		exit 8
	}

#
# Search for ICAO IDs specified as parameters
#
	for ( $parmctr = 0; $parmctr -lt $parmnum; $parmctr++ ) {
		
		$procarrelem = ""							# Prepare Element-String (later filled into ArrayList $procarraprw)
#		
		$parmicao = $args[$parmctr]					# Process next commandline parameter
		write-host " "
		$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
		write-host "$timestmp === Processing ICAO-ID [$parmicao] ==="

		$parmicao = $parmicao.ToUpper()				# P2A DB contains ICAO IDs in uppercase
		if ( $parmicao.Length -ne 4 ) {
			$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
			write-host ( "$timestmp --- Skipping ICAO ID $parmicao (must have 4 chars!) ---" )
			continue								# process next element in "for $parmctr" loop
		}
		$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
		write-host ( "$timestmp --- Lookup ICAO ID $parmicao in XML-File ---" )
#
# Lookup ICAO ID in Makerwys runway.xml
#
		$xmlAP = $xmlAirports.data.ICAO | where-object id -eq $parmicao
		$xmlapICAO = $xmlAP.id						# runways.xml id is ICAO ID
		$xmlapName = $xmlAP.ICAOName						# runways.xml id is ICAO ID
		if ( [String]::IsNullOrEmpty($xmlapICAO)) {
			write-host ( "$timestmp Error ICAO ID $parmicao not in $mkrwxmlf in DB with ID $dbapId, skipping" )
			continue									# process next element in "for $parmctr" loop
		}
		if ( -not  [String]::IsNullOrEmpty($xmlapName)) {
			$txtapName = "(" + $xmlapName + ")"
		} else {
			$txtapName = ""
		}
		write-host ( "$timestmp Found ICAO ID  $parmicao $txtapName in $mkrwxmlf" )
		$xmlapCountry = $xmlAP.Country
		$xmlapCity	= $xmlAP.City
		$xmlapLong	= $xmlAP.Longitude
		$xmlapLat	= $xmlAP.Latitude
		$xmlapAlt	= $xmlAP.Altitude
		$xmlapMagV	= $xmlAP.MagVar
		$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
	    write-host ( "$timestmp XML Long: $xmlapLong Lat: $xmlapLat Alt: $xmlapAlt MagVar: $xmlapMagV City: $xmlapCity Country: $xmlapCountry" )
	
#
# Lookup ICAO ID in P2A SQLite Database
#

<# ################## Temporarily inserted for debugging: delete ZGWZ Wuzhou before checking for existence ########
#
write-host "###DEBUG### Removing ZGWZ from airports database if it exists"
$SqlQuery = "delete from " + $p2adyndbaptab + " where ICAO_Code = 'ZGWZ';"
if ( $flgdebug -eq $true ) { write-output "**DBG SQLite on DB $p2adyndbfile" "**DBG Cmd: $SqlQuery" }	# Debug-Message
Invoke-SqliteQuery -Query "$SqlQuery" -DataSource $p2adyndbfile
write-host "###DEBUG### End"
#
# ################## End of temporary insertion ##################################################################	#>
		$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
		write-host ( "$timestmp --- Check ICAO ID $parmicao not existing in table $p2adyndbaptab ---" )
		$SqlQuery = "select * from " + $p2adyndbaptab + " where ICAO_Code = '" + $parmicao + "';"
		if ( $flgdebug -eq $true ) { write-output "**DBG SQLite on DB $p2adyndbfile" "**DBG Cmd: $SqlQuery" }	# Debug-Message
		$DBairport = Invoke-SqliteQuery -Query "$SqlQuery" -DataSource $p2adyndbfile
		if ( -not [String]::IsNullOrEmpty($DBairport.id)) {
			$dbapId		= $DBAirport.Id				# P2A DB Id is DB-internal AUTONUMBER id
			$dbapName	= $DBAirport.Name
			$dbapICAO	= $DBAirport.ICAO_Code
			$dbapElev	= $DBAirport.Elevation
			$dbapMagV	= $DBAirport.MagVar
			$dbapLat	= $DBAirport.Position_Latitude
			$dbapLong	= $DBAirport.Position_Longitude
			$dbapCtCd	= $DBAirport.CountryCode
			$dbapCtry	= $DBAirport.Country
			$dbapCity	= $DBAirport.City
			$dbapTrans	= $DBAirport.TransitionAltitude
			$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
			write-host ( "$timestmp Error ICAO ID $dbapICAO : $dbapName exists in DB with ID $dbapId, DB fields:" )
			write-host ( "$timestmp DB  Long: $dbapLong Lat: $dbapLat Elev: $dbapElev MagVar: $dbapMagV City: $dbapCity Country: $dbapCtry Trans.Alt: $dbapTrans " )
			write-host ( "$timestmp $dbapICAO skipped" )
			continue									# process next element in "for $parmctr" loop
		}

#
# Airport doesn't exist in P2A Database, so add it
#
		write-host ( "$timestmp --- Check for missing parameters of ICAO ID $parmicao ---" )

# DB Parameters not in runways.xml
		$unknTransAlt	= 0			# Transition Altitude not in runways.xml, set to 0
		$unknCity		= ""		# Airport City
#
# Add some missing content by asking the user
#
		if ( [String]::IsNullOrEmpty($xmlapName)) {
			write-host ( "$timestmp $xmlapICAO Airport Name is empty, please tell it or just press ENTER key" )
			$xmlapName = Read-Host -prompt "??? Airport Name (or ENTER key for none) "
		}
		if ( [String]::IsNullOrEmpty($xmlapCity)) {
			write-host ( "$timestmp $xmlapICAO Airport City is empty, please tell it or just press ENTER key" )
			$xmlapCity = Read-Host -prompt "??? Airport City (or ENTER key for none) "
		}
# ICAO ID and Name in uppercase
		$xmlapICAO = $xmlapICAO.ToUpper()
		$xmlapName = $xmlapName.ToUpper()
		
# Last chance to abort

		$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
		write-host "$timestmp Inserting these airport data in P2A DB $p2adyndbaptab"
		write-host "ICAO:		[$xmlapICAO]"
		write-host "Name:		[$xmlapName]"
		write-host "City:		[$xmlapCity]"
		write-host "Longitude:	[$xmlapLong}"
		write-host "Latitude:	[$xmlapLat]"
		write-host "Elevation:	[$xmlapAlt]"
		write-host "MagVar:		[$xmlapMagV]"
		write-host "TransAlt:	[$unknTransAlt]"
	
#
# Ask user for DB update 
#
		$answer = Read-Host -prompt "??? Add ICAO ID $xmlapICAO to DB $p2adyndbaptab ? Please answer Y or N "
		if ( $answer.ToLower() -eq "y" ) {
			write-host " "
			write-host ( "$timestmp --- Add ICAO ID $xmlapICAO to database $p2adyndbaptab ---" )
# Important 1 !
#	The DB field "id" must not be filled as it is filled by its SQLite AUTONUMBERING definition!
# Important 2 !
# 	To avoid SQL-Injection according to https://www.spech.de/2016/06/sqlite-mit-der-powershell-nutzen/:
#	The INSERT sets up a relation between the DB-fields (e.g. "ICAO_Code")
#	and a virtual parameter of Invoke-SqliteQuery (e.g. "@ICAO").
#	The Invoke-SqliteQuery assigns the content (variables, constants) to thesee virtual parameters
#	(e.g. INSERT ICAO_Code ->  @ICAO -> Invoke-SqliteQuery ICAO <- variable $xmlapICAO)
# Diese Logik aus https://www.spech.de/2016/06/sqlite-mit-der-powershell-nutzen/
			$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
			write-host ( "$timestmp Prepare DB INSERT for ICAO ID $xmlapICAO" )

#
# Insert new airport into Airport-DB
#
			$sqladdap = "INSERT INTO " + $p2adyndbaptab + 
						" (Name, ICAO_Code, City, Elevation, MagVar, Position_Latitude, Position_Longitude, TransitionAltitude)" + 
						" VALUES (@Name, @ICAO, @City, @Elevation, @MagVar, @Latitude, @Longitude, @TransAlt)"
			if ( $flgdebug -eq $true ) { write-output "**DBG SQLite on DB $p2adyndbfile" "**DBG Cmd: $sqladdap" }	# Debug-Message
			Invoke-SqliteQuery -Query "$sqladdap" -DataSource $p2adyndbfile -SqlParameters @{
				Name		= $xmlapName
				ICAO		= $xmlapICAO
				City		= $xmlapCity
				Elevation	= $xmlapAlt
				MagVar		= $xmlapMagV
				Latitude	= $xmlapLat
				Longitude	= $xmlapLong
				TransAlt	= $unknTransAlt
			}
#
# Check (display) result from table airports
#
			$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
			write-host ( "$timestmp Read back DB airport table $p2adyndbaptab for ICAO ID $xmlapICAO" )
			$SqlQuery = "select * from " + $p2adyndbaptab + " where ICAO_Code = '" + $parmicao + "'"
			if ( $flgdebug -eq $true ) { write-output "**DBG SQLite on DB $p2adyndbfile" "**DBG Cmd: $SqlQuery" }	# Debug-Message
			Invoke-SqliteQuery -Query "$SqlQuery" -DataSource $p2adyndbfile

#
# Check/prepare insert into table airports preparing the runway addition (we need the airport's database ID as foreign key)
#
			$SqlQuery = "select id from " + $p2adyndbaptab + " where ICAO_Code = '" + $parmicao + "'"
			if ( $flgdebug -eq $true ) { write-output "**DBG SQLite on DB $p2adyndbfile" "**DBG Cmd: $SqlQuery" }	# Debug-Message
			$airportdbid = Invoke-SqliteQuery -Query "$SqlQuery" -DataSource $p2adyndbfile
			if ( ( $airportdbid.id -is [int] ) -or ( $airportdbid.id -is [int64] ) ) {
				$procarrelem = "$xmlapICAO[" + $airportdbid.id + "]"		# Add airport ICAO and its DB-ID to Element-String (later filled into ArrayList $procarraprw)
#
# Process runway obj
#
				$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
				write-host ( "$timestmp Processing runways for Airport $parmicao with DB-ID " + $airportdbid.id )
				foreach ($aprunway in $xmlAP.Runway) {
					$rwName = "RW" + $aprunway.id
					$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
					write-host " "
					write-host ( "$timestmp --- Processing runway  $rwname  for ICAO ID $parmicao ---" )
#
					$rwElev = $xmlapAlt			# no separate runway altitude in runway.xml, so we take the airport alt
					$rwLength = $aprunway.Len
					$calcWidth = $rwLength	# we have to calculate from runway length by my miraculous formula ;-)
					$calcWidth = [math]::min($calcWidth,6000) ; $calcWidth = [math]::max($calcWidth,1000) ; $calcWidth = $calcWidth / 25
					$rwWidth = $calcWidth # truncate runway length to 1000...6000, then divide by 25 will be our assumed runway width
					$rwHeading = $aprunway.Hdg
					$rwPatternAltitude = $aprunway.PatternAltitude
# XML ClosedTakeoff and ClosedLanding have to be inverted as XML FALSE/TRUE become in DB Takeoff/Landing are not closed = 1 or closed = 0
					if ($aprunway.ClosedTakeoff -eq "FALSE") { $rwTakeoff = 1 } else { $rwTakeoff = 0 }	# Inverted: ClosedTakeoff = FALSE -> Takeoff =1 as Takeoff is possible
					if ($aprunway.ClosedLanding -eq "FALSE") { $rwLanding = 1 } else { $rwLanding = 0 }
					$rwPosition_Latitude = $aprunway.Lat
					$rwPosition_Longitude = $aprunway.Lon
					$rwType = 1 # always 1 in existing DB airports
					$rwAirport_Id = $airportdbid.id	# DB autonumbered ID of line in table runways
#					
# Show values to be inserted
#
					$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
					write-host "Runway $rwName for Airport DB-ID $rwAirport_Id"
					write-host "       Elevation $rwElev, Length $rwLength, Width $rwWidth, Heading: $rwHeading"
					write-host "       PatternAltitude $rwPatternAltitude, Takeoff enabled = $rwTakeoff, Landing enabled = $rwLanding"
					write-host "       Pos Lat: $rwPosition_Latitude, Pos Long $rwPosition_Longitude Type $rwType"

#
# Insert Runway into DB Table runways
#
					$sqladdrw = "INSERT INTO " + $p2adyndbrwtab + 
								" (Name, Elevation, Length, Width, Heading, PatternAltitude, Takeoff, Landing, Position_Latitude, Position_Longitude, Type, Airport_Id) " + 
								" VALUES (@Name, @Elevation, @Length, @Width, @Heading, @PatternAltitude, @Takeoff, @Landing, @Position_Latitude, @Position_Longitude, @Type, @Airport_Id)"
					if ( $flgdebug -eq $true ) { write-output "**DBG SQLite on DB $p2adyndbfile" "**DBG Cmd: $sqladdrw" }	# Debug-Message		
					Invoke-SqliteQuery -Query "$sqladdrw" -DataSource $p2adyndbfile -SqlParameters @{
						Name		= $rwName
						Elevation	= $rwElev
						Length		= $rwLength
						Width		= $rwWidth
						Heading		= $rwHeading
						PatternAltitude = $rwPatternAltitude
						Takeoff		= $rwTakeoff
						Landing		= $rwLanding
						Position_Latitude = $rwPosition_Latitude
						Position_Longitude = $rwPosition_Longitude
						Type		= $rwType
						Airport_Id	= $rwAirport_Id
						
					}
#
# Check (display) result from table runways
#
					$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
					write-host ( "$timestmp Read back DB runway table $p2adyndbrwtab for Airport DB-ID $rwAirport_Id" )
					$SqlQuery = "select * from " + $p2adyndbrwtab + " where Airport_Id = $rwAirport_Id and Name = '$rwName'"
					if ( $flgdebug -eq $true ) { write-output "**DBG SQLite on DB $p2adyndbfile" "**DBG Cmd: $SqlQuery" }	# Debug-Message		
					Invoke-SqliteQuery -Query "$SqlQuery" -DataSource $p2adyndbfile
#
# Check/prepare insert into table runways
#
					$SqlQuery = "select id, Name from " + $p2adyndbrwtab + " where Airport_Id = '" + $rwAirport_ID + "' and Name = '" + $rwName + "'"
					if ( $flgdebug -eq $true ) { write-output "**DBG SQLite on DB $p2adyndbfile" "**DBG Cmd: $SqlQuery" }	# Debug-Message		
					$runwaydbid = Invoke-SqliteQuery -Query "$SqlQuery" -DataSource $p2adyndbfile
					if ( ( $runwaydbid.id -is [int] ) -or ( $runwaydbid.id -is [int64] ) ) {
						$dbrwName = $runwaydbid.Name
<# write-host "##### DEBUG: dbrwName: $dbrwName #####" #>
						if ( -not [String]::IsNullOrEmpty($dbrwName)) {
							$procarrelem = " $procarrelem " + "$dbrwname[" + $runwaydbid.id + "]"		# Add runway Name and its DB-ID to Element-String (later filled into ArrayList $procarraprw)
						} else {
							$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
							write-host ("$timestmp Error in table runways: runway name for DB-ID " + $runwaydbid.id + " is empty, please check manually")
						}
					} else {
						$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
						write-host ("$timestmp Error in table runways: runway DB-ID for airports DB-ID" + $rwAirport_ID + " and RW-Name + " + $rwName + " is empty, please check manually")
					}
# End of "foreach $aprunway" loop
				}
				
			} else {
				$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
				write-host ( "$timestmp Error: cannot read database ID of recently added airport $parmicao," )
				write-host ( "$timestmp        skipping runway addition, please check manually!" )
			}
			
		} else {
			$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
			write-host ( "$timestmp $dbapICAO DB-Update skipped on user request" )
		}
#		
# Add element with processed airport and its runways to ArrayList if not empty
#
		if ( -not [String]::IsNullOrEmpty($procarrelem)) {
			$procarraprw.add($procarrelem)		# Array of processed airports and their runways
		}

# End of "for $parmctr" loop	
	}

#
# Output of ArrayList with processed airports and runways
#
	write-host " "
	$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
	write-host ( "$timestmp === List of successfully processed airports and their runways, each with DB-ID ===" )
	foreach ($arrelem in $procarraprw) {
		write-host "-> $arrelem"
	}
# Ending message
	$timestmp = Get-Date -format "dd.MM.yy hh:mm:ss"
	write-host "$timestmp === $myScrNm $myver ended ==="
#
exit 0
