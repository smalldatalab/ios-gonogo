# Cued Go/No-Go Task
======

This is the repository for the iOS Go/No-Go impulsivity task.

## Background

Research:

* http://www.impulsivity.org/measurement/cued_Go_NoGo
* http://www.ncbi.nlm.nih.gov/pmc/articles/PMC2787090/

Online Version:

* http://www.millisecond.com/download/library/GoNoGo/

## How to Build the Project

In order to run the app, you will need to add a configuration file with your OAuth IDs.

Add `Secrets.plist` under `Go-No-Go/Go-No-Go/`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>GoogleClientID</key>
	<string>(1) Google Client ID</string>
	<key>DSUClientSecret</key>
	<string>(2) DSU Client Secret</string>
</dict>
</plist>

```