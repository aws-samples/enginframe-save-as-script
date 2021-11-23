## EnginFrame save as script action

<b>The code enables NICE EnginFrame HPC portal services to save themselves as standalone submission scripts.</b><br/>
These scripts can be executed by the user in a later time without accessing the portal, from a command line.

Saving the service as a standalone submission script can cover a number of customer cases, such as:
- Need to submit several instances of the same HPC job manually or within wrapper scripts (e.g. in case of multiple realization jobs)
- Users preferring to submit their jobs from terminals, ssh or DCV sessions
- Build custom jobs workflows and automations, where this submission script becomes a step
- Enable users to work even if the portal is down
- Test/validate job scripts in a quicker way

Please review and accept EnginFrame EULA: https://download.enginframe.com/eula.html

## Overview of solution
We’ll implement this function by just modifying the Action Script of our target service.
The logic we’ll put in place is the following:
1.	Get required information from the environment (service id, full path to service scripts, service option id list)
2.	For each service option id, dump its environment variable name and value into the target script
3.	Dump standard environment variables automatically exported by the portal (e.g. EF_ROOT, EF_USER, etc) into the target script
4.	Translate submission options passed to portal application.submit wrapper into standard HPC scheduler submission options (that’s the scheduler-dependent section)
5.	If submission options include MyHPC ones, dump them as well
6.	Save the script under _${HOME}/enginframe/saved.scripts_
7.	Redirect the user to the spooler containing the script, just like application.submit would have done. In here the user can find a downloadable copy of the target script 

## Walkthrough
### Prerequisites
- You know EnginFrame software and you are an EnginFrame administrator
-	Your service Action script must use the standard EnginFrame submission wrapper: applications.submit 
E.g. it should use standard applications.submit command line options such as --jobname, 
--submitopts etc..
-	Your service Action script must collect applications.submit options into one args() bash array (the default)
-	If you’re using MyHPC AWS Professional Services solution, there should similarly be 2 other bash arrays e.g. myhpc_cunit() and myhpc_tags() that collect MyHPC options and tags. Also, args() array mentioned above must not include any MyHPC option, i.e. the arrays must not define the same submission parameters. Similar instructions could be applicable to Scale out computing on AWS (SOCA) solution.
-	Since the code is bound to the underlying scheduler used, it might vary a little. In this document I’ll refer to PBS scheduler (working with OpenPBS or Altair PBS Pro but it should be easily portable to other schedulers supported by EnginFrame

### Steps
To enable this feature to your service, proceed in the following way:
1) Edit target service with EnginFrame service editor
2)	Add Save as script, don't submit checkbox/boolean option with id: save_as_script and class save-as-script, default value: true
3)	To disable the standard Submit button if our new checkbox is checked, we’ll add a little JavaScript code. Go To Settings → Javascript and add **service.js** code
4)	Finally, let’s find a place in our Action script that meets all the Requirements above, in particular where args() and other optional myhpc() arrays contain all the desired options, and those options are not overlapping. Then paste there the **action-script.sh** code

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

