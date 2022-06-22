# semreg-cli
To use this CLI in your jobs you need to do the following

### Step 1 - install the CLI
Installation :

`wget https://raw.githubusercontent.com/renderedtext/snippets/master/semreg -O semreg && source semreg`

### Step 2 - connect to your registry
The environment variables listed below are used to connect to the registry.
Make sure that the variable values are set correctly. 
`SEMAPHORE_REGISTRY_USERNAME` : username for the connection  
`SEMAPHORE_REGISTRY_PASSWORD` : password for the connection  
`SEMAPHORE_REGISTRY_HOST` : can be DNS name or IP address of the registry  

### Step 3 - Use the CLI
Usage: `semreg [prune|list|usage]`

list : Displays images in the registry  
Usage:  
  `semreg list`  
Example output:
```
Image   Tag         CreatedAt               Size
first   5           2021-07-06_11h-09m-27s  236927067
first   1           2021-07-06_11h-08m-49s  236927066.
```
usage : Displays registry space usage.
Usage:  
  `semreg usage`
Example output:
```
Size   Used   Available
\"49G\"  \"53M\"  \"47G\".
```
prune: Bulk removes unused images from the Semaphore Private Docker Registry.  
Usage:  
  `semreg prune [all | image-name] [flags…]`

Default behaviour:  
Deletes all images older than one day.

Flags:  
  `--one-week` - Deletes all images older than one week old.  
  `--retain N` - Deletes all images, leaves the newest N images in the registry.  
  `--skip TAGS` - Deletes all tags, except the ones specified.(to be implemented)  

`semreg prune all`  
Delete all images older than one day.

`semreg prune all --one-week`  
Delete all images older than one week.

`semreg prune all --retain 3`  
Delete all images except the last 3.

`semreg prune all --retain 1`  
Delete all images except the last .

`semreg prune <image name>`  
Delete all tags from <image name> older than one day.

`semreg prune <image name> --one-week`  
Delete all tags from <image name> older than one week.

`semreg prune <image name> --retain 3`  
Delete all tags from <image name> except the last 3.

`semreg prune <image name> --retain 1`  
Delete all tags from <image name> except the last one."
