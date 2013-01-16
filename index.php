<html>
<head>
    <title>

    </title>

    <style type="text/css">

        #header{
            float: left;
            width: 100%;
            height: 10%;
        }
        #left{
            float: left;
            width: 20%;
            height: 90%;
        }
        #mid{
            float: left;
            width: 60%;
            height: 90%;
        }
        #right{
            float: left;
            width: 20%;
            height: 10%;
        }
        #login{
            float: left;
            width: 200px;
            height: 300px;
        }
        #myContent{
            float: left;
        }

    </style>

    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
    <script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
    <script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js"></script>

    <script type="text/javascript">
    swfobject.embedSWF("socketClient.swf", "myContent", "720", "480", "9.0.0");
    </script>
</head>
<body>
 <div id="fb-root"></div>
    <script>
        var access_token=null;
      // Additional JS functions here
      window.fbAsyncInit = function() {
        FB.init({
          appId      : '523977007634071', // App ID
          //channelUrl : '//WWW.YOUR_DOMAIN.COM/channel.html', // Channel File
          status     : true, // check login status
          cookie     : true, // enable cookies to allow the server to access the session
          xfbml      : true  // parse XFBML
        });

        // Additional init code here
            // connected
          FB.getLoginStatus(function(response) {
          if (response.status === 'connected') {
              testAPI() ;
              console.log("access token is::"+response.authResponse.accessToken);
              access_token=  response.authResponse.accessToken;
              console.log('connected');
          } else if (response.status === 'not_authorized') {
            // not_authorized
              console.log('not_authorized');
              login();
          } else {
            // not_logged_in
              console.log('not_logged_in');
              login();
          }
         });


      };


        function callback(response) {
          //document.getElementById('msg').innerHTML = "Post ID: " + response['post_id'];
            /*
            FB.api('/'+response['post_id']+'/likes?access_token='+access_token, 'post', function(resp) {
              console.log(resp);
            });
            FB.api('/'+response['post_id']+'/comments?access_token='+access_token, 'post',{message: 'bulla'},function(resp) {
              console.log(resp);
            });
            */
           console.log(response['post_id']);
        }



      function login() {
        FB.login(function(response) {
            if (response.authResponse) {
                // connected
                //testAPI();
              console.log("access token is::"+response.authResponse.accessToken);
                access_token=  response.authResponse.accessToken;


            } else {
                // cancelled
            }
        });

    }

      function testAPI() {
        console.log('Welcome!  Fetching your information.... ');
        FB.api('/me', function(response) {
            console.log('Good to see you, ' + response.name + '.');
        });
    }

      // Load the SDK Asynchronously
      (function(d){
         var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];
         if (d.getElementById(id)) {return;}
         js = d.createElement('script'); js.id = id; js.async = true;
         js.src = "//connect.facebook.net/en_US/all.js";
         ref.parentNode.insertBefore(js, ref);
       }(document));
    </script>

    <div id="header">

    </div>

    <div id="left">

    </div>

    <div id="mid">
        <div id="myContent">
          <p>Alternative content</p>
        </div>
    </div>

    <div id="right">
        <div id="login">

        </div>
    </div>


</body>
</html>