#!/bin/sh

function Usage() {
 	echo "Usage: html.sh html_file_name html_file_title "
	return 1
}

if [ $3 -eq 2 ]; then
style='body, h1, h2, p{ margin:0px; padding:0px; }
#header,#footer{ position:relative; margin:0 auto; width:1000px; background-color:#D7E3F4; }
#header{ height:100px; }
#main_content{ width:1000px; position:relative; margin:0 auto; height:550px; margin-top:10px; }
#footer{ height:100px; margin-top:10px; }
#aritcle{ float:left; width:300px; background-color:#F0F8FB; height:550px; }
#content{ float:left; width:690px; background-color:#80ABE5; margin-left:10px; height:550px; }
'
elif [ $3 -eq 3 ]; then
style='body, h1, h2, p{ margin:0px; padding:0px; }
#header,#footer{ position:relative; margin:0 auto; width:1000px; background-color:#D7E3F4; }
#header{ height:100px; }
#main_content{ width:1000px; position:relative; margin:0 auto; height:550px; margin-top:10px; }
#footer{ height:100px; margin-top:10px; }
#aritcle{ float:left; width:300px; background-color:#F0F8FB; height:550px; }
#content{ float:left; width:350px; background-color:#80ABE5; margin-left:10px; height:550px; }
#aside{ float:left; width:330px; background-color:#80ABF5; margin-left:10px; height:550px; }
'
else
	exit 1 
fi

cat > $1.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
<title>$2</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<style type="text/css">
${style}
</style>
</head>
<div id="header">
$2
</div>
<div id="main_content">
<div id="aritcle">
$2
</div>
<div id="content">
$2
</div>
<div id="aside">
</div>
</div>
<div id="footer">
$2
</div>
<body>
</body>
EOF

if [[ $# != 3 ]]; then
	Usage

fi
