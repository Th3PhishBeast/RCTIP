<?php
    
    if (isset($_POST["send"])) {
      $to = $_POST["to"];
      $from = $_POST["from"];
      $message = $_POST["message"];
      //open connection
              $ch = curl_init();

              //set the url, number of POST vars, POST data
              curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
              curl_setopt($ch, CURLOPT_USERPWD, 'API_KEY:API_PASSWORD');
              curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_ANY); 
              curl_setopt($ch, CURLOPT_URL, sprintf('https://api.twilio.com/2010-04-01/Accounts/API_KEY/Messages.json', 'API_KEY'));
              curl_setopt($ch, CURLOPT_POST, 3);
              curl_setopt($ch, CURLOPT_POSTFIELDS, 'To='.$to.'&From='.$from.'&Body='.$message);

              //execute post
              $result = curl_exec($ch);
              $result = json_decode($result);
            
              //close connection
              curl_close($ch);

              if($result) {
               $success = "Message sents";
              }else{
                $error = "Sent failed";
              } 
    }

    //This script has been developed with love by ADELEYE AYODEJI => adeleyeayodeji.com
    //Having issues, am always ready to help.

?>
<!DOCTYPE html>
<html>
<head>
  <title>Send message to your phone</title>
  <link rel="stylesheet" type="text/css" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css">
  <script type="text/javascript" src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js"></script>
  <script type="text/javascript" src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.bundle.min.js"></script>

</head>
<body>
  <div class="container">
    <div class="header" style="padding: 20px;">
      <h2 style="text-align: center;">A Simple PHP SMS API</h2>
    </div>
    <div class="main">
        <form method="post" action="">
          <div class="form-group">
            <label>
              From: <code>[Your Valid Purchased Number]</code>
            </label>
            <input type="text" name="from" class="form-control" required="">
          </div>
          <div class="form-group">
            <label>To: <code>[Any International Number]</code></label>
            <input type="text" name="to" class="form-control" required="">
          </div>
          <div class="form-group">
            <label>Message</label>
            <textarea class="form-control" required="" name="message"></textarea>
          </div>
          <div class="form-group">
            <input type="submit" name="send" value="Send Message" class="btn btn-large btn-primary">
          </div>
          <?php
            if (isset($success)) {
              ?>
              <div class="alert alert-success" role="alert">
                Message sents to <?php echo $to; ?>
              </div>
              <?php
            }

             if (isset($error)) {
              ?>
              <div class="alert alert-danger" role="alert">
                Failed to send message to <?php echo $to; ?>
              </div>
              <?php
            }
          ?>
        </form>
        <div class="footer">
        	<a href="http://adeleyeayodeji.com/" target="_blank">Having Problem with the sourcecode, Contact the developer</a>
        </div>
    </div>
  </div>

</body>
</html>