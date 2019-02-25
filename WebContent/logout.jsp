<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <title>New BankingWeb</title>
  <link rel="icon" type="image/png" href="images/favicon.ico">
</head>
<body>
<img src="images/logo.png" alt="Acmebank Inc."/>
<H2>BankingWeb</H2>
<form method="post" name="login">
	<fieldset>
	User logged out. Click <a href='index.jsp'>here</a> to login again
	</fieldset>
</form>
<p>Deployed by: ${job_name} From Brasil</p> 
<p>Environment: ${bl}</p>
<p>This version is adapted to release 3.7</p>
<p>Empowered by Clarive ${clarive_version} on ${job.starttime}</p>
</body>
</html>
