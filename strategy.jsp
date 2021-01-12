<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<html lang="en">
<head>
    <title>Console</title>
      <link rel="stylesheet" href="/css/jquery-ui.min.css" type="text/css" />
      <script src="/webjars/jquery/jquery.min.js"></script>
      <script src="/webjars/sockjs-client/sockjs.min.js"></script>
      <script src="/webjars/stomp-websocket/stomp.min.js"></script>
      <script src="https://code.jquery.com/jquery-3.4.1.js"></script>
      <style>
        html {
            font-family: sans-serif, system-ui, "Open Sans", Frutiger, Calibri;
            font-size:80%;
        }
                  textarea {
                      width: 1300 px;
                      height: 30em;
                      scrollbar-base-color: #ff8c00;
                      scrollbar-arrow-color: white;
                  }
      #uploadbutton {
          margin: 1px 1px 1px 1px
          padding: 5px
      }
      /* The popup form - hidden by default */
      .form-popup {
        display: none;
        position: sticky;
        bottom: 0;
        right: 0;
        background-color: #cae8ca;
        border: 2px solid #4CAF50;
        overflow: scroll;
        text-align: center;
      }
    </style>

      <script>

      function removeline(element) {
        element.contents().first().remove();
      }

            function getRowNo(element) {
            var lineHeightBefore = element.css("line-height"),
                  boxSizing        = element.css("box-sizing"),
                  height,
                  lineCount;

              // Force the line height to a known value
              element.css("line-height", "1px");

              // Take a snapshot of the height
              height = parseFloat(element.css("height"));

              // Reset the line height
              element.css("line-height", lineHeightBefore);

              if (boxSizing == "border-box") {
                // With "border-box", padding cuts into the content, so we have to subtract
                // it out
                var paddingTop    = parseFloat(element.css("padding-top")),
                    paddingBottom = parseFloat(element.css("padding-bottom"));

                height -= (paddingTop + paddingBottom);
              }

              // The height is the line count
              lineCount = height;

//              if (lineCount>26){
//              removeline(element);
//              }
                return lineCount;

            }
           function scrollToBottom(e) {
               e.scrollTop($("#logconsole")[0].scrollHeight);
           }

          $( "select" ).change(function() {
              var str = "";
              $( "select option:selected" ).each(function() {
                  alert($( this ).text());
              });
          });
          var stompClient = null;
          var session_id = '<%=session.getId()%>';
          function setConnected(connected) {
              $("#connect").prop("disabled", connected);
              $("#disconnect").prop("disabled", !connected);
              if (connected) {
                  $("#conversation").show();
              }
              else {
                  $("#conversation").hide();
              }
              $("#logconsole").html("");
          }

          function connect() {
              var socket = new SockJS('/strategy_fetch');
              stompClient = Stomp.over(socket);
              stompClient.connect({}, function (frame) {
                  setConnected(true);
                  console.log('Connected: ' + frame);
                  stompClient.subscribe('/wsTopic/strategy', function (console) {
                        if (session_id==JSON.parse(console.body).sessionid){
                            if (JSON.parse(console.body).parameter.startsWith(":AUTOUPDATE-")){
                                $("#logconsole").empty();
                                showGreeting(JSON.parse(console.body).parameter.substring(12));
                            } else if (JSON.parse(console.body).parameter.startsWith(":DOWNLOAD-")){
                                showAnchorGreeting(JSON.parse(console.body).parameter.substring(10));
                            } else if (JSON.parse(console.body).parameter.startsWith(":POPUP-")){
                                showPopupGreeting(JSON.parse(console.body).parameter.substring(7));
                            } else {
                                showGreeting(JSON.parse(console.body).parameter);
                            }
                        }
                  });
              });
              showGreeting("Server conneced.");
          }

          function disconnect() {
              if (stompClient !== null) {
                  stompClient.disconnect();
              }
              setConnected(false);
              console.log("Disconnected");
          }

          function shutdown() {
              stompClient.send("/mdcon/command", {}, JSON.stringify({'sessionid': session_id,'order': 'shutdown',}));
          }
          function submitcommand(paras) {
              showGreeting(paras);
              $("#command").val('');
              stompClient.send("/mdcon/command", {}, JSON.stringify({'sessionid': session_id,'order': 'command', 'parameters':paras}));
          }
          function clear() {
              $("#logconsole").empty();
          }

          function showGreeting(message) {
                $("#logconsole").append(message + "<br>");
                scrollToBottom($("#logconsole"));
          }

          function showAnchorGreeting(message) {
              $("#logconsole").append( "<a href='/download/"+message+"'>"+message + "</a><br>");
          }

          function showPopupGreeting(message) {
              $("#logconsole").append( "<a href='javascript:openForm(\"/download/"+message+"\")'>"+message + "</a>");
              $("#logconsole").append( "<p>");
          }

          $(function () {
              $("#fileload").click(function() { return;});

              $("#wsform").on('submit', function (e) {
                  e.preventDefault();
              });


              $( "#connect" ).click(function() { connect(); });
              $( "#disconnect" ).click(function() { disconnect(); });

              $( "#clear" ).click(function() { clear(); });
              $( "#command" ).change(function() {
                  var comsend = $( "#command" ).val();
                  submitcommand(comsend);
              });
          });

              function openForm(chartlink) {
                document.getElementById("chartimage").src=chartlink;
                document.getElementById("chartdiv").style.display = "block";
              }

              function closeForm() {
                document.getElementById("chartdiv").style.display = "none";
              }

      </script>

</head>
<body onload="connect()">
<ul id="menu-main" class="menu genesis-nav-menu">
    <div class="nav-header">
            <span itemprop="name">
                <h3>TradingStrategy</h3>
            </span>
    </div>
</ul>
  <!--- check login status and display message -->
<script src="/js/bootstrap.min.js"></script>
<div id="main-content" >
    <div >
        <div>
            <form  id = "wsform" action="/marketdata">
                <div >
                    <button id="connect" class="btn btn-default navbar-btn navbar-toggle" type="submit">Connect</button>
                    <button id="disconnect" class="btn btn-default navbar-btn navbar-toggle" type="submit" disabled="disabled">Disconnect</button>
                    <button id="clear" class="btn btn-default navbar-btn navbar-toggle" type="submit">Clear</button>
                    <label style="font: 11px 'Courier New', Courier, monospace;"><%=session.getId()%></label>
                    <p>
                    <input type="text" id="command" class="input" placeholder="......" size=100>
                </div>
            </form>

        </div>
    </div>


    <div  id="logconsole" style="background-color:#f4f4f4; width: 1200px; overflow: auto; height: 400px; font: 400 11px system-ui; color: #550000">
        <table id="conversation" class = "table">
            <!--tbody id="logconsole" style="font: 11px 'Courier New', Courier, monospace;">
            </tbody-->
            <div >
            </div>
        </table>
    </div>

    <div class="form-popup" id="chartdiv">
        <img src="" id="chartimage" alt="chart" /><br>
        <button type="button" class="btn cancel" onclick="closeForm()">Close</button>
    </div>

    <table class = "table">
        <tr>
            <td><form method="POST" enctype="multipart/form-data" action="/strategy/symbolfile">
                        <input type="hidden" id ="sessionid" name="sessionid" value="<%=session.getId()%>">
                        Symbol File:<input type="file" name="symbolfile" /><input type="submit" id="uploadbutton" value="Symbol File Upload" />
                </form></td>
        </tr>
        <tr>
            <td><form method="POST" enctype="multipart/form-data" action="/strategy/yahoofile">
                    <input type="hidden" id ="sessionid" name="sessionid" value="<%=session.getId()%>">
                    Yahoo File:<input type="file" name="yahoofile" /><input type="submit" id="uploadbutton" value="Yahoo File Upload" />
                </form></td>
        </tr>
        <tr>
            <td><form method="POST" enctype="multipart/form-data" action="/strategy/planfile">
                        <input type="hidden" id ="sessionid" name="sessionid" value="<%=session.getId()%>">
                        Plan File:<input type="file" name="planfile" /><input id="uploadbutton" type="submit" value="Plan File Upload" />
                </form></td>
        </tr>
    </table>
    <br>

</div>

</body>
</html>