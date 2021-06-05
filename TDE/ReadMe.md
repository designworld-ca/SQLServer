# Implementing Transparent Data Encryption

Simple in theory, tricky in practice...available since SQL Server 2008 and often required by PCIS grade audits 
or where personally identifiable information is found

These scripts show what to check and how to implement TDE at an enterprise level.  This is not intended to be applicable to
cloud environments like Azure.

All scripts tested on SQL Server 2016 Developer edition.

## Potential issues when deploying
1. tempDb is encrypted as well leading to a performance hit  => assess applications that cause large use of tempDb, consider having 8 tempDb files that are all the same size and set to the maximum size.  (this way the engine does not have to take time to resize the files under heavy use)
2. reading and writing takes fractionally longer as encryption is done as well.  => assess applications that cause heavy writes as they may be subject to a performance hit.  Resolve with faster storage

## Foolproof deployment
1. Confirm master key and certificate exist or create them on the instance
2. Create a dummy database and encrypt which causes the tempDb to be encrypted
3. Wait and see if there are any side effects particularly during periods of high use such as month end
4. If there are side effects 
   1. unencrypt and drop the dummy database 
   2. restart the SQL Server service
   3. verify the tempDb is now unencrypted
5. If there are no side effects then encrypt the databases

