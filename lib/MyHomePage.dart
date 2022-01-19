import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String currentWeatherApi = 'http://api.openweathermap.org/data/2.5/weather?';
  String forecastApi = 'http://api.openweathermap.org/data/2.5/forecast?';

  String apiId = "";  // TODO: SET API KEY FORM openweathermap.org
  String units = "units=metric&";

  var currentWeatherData;
  List forcastDataList;

  @override
  void initState() {
    super.initState();

    String cityName = "q=Delhi,IN";
    this.getCurrentWeatherData(cityName);
    this.getForecastWeatherData(cityName);
  }

  Future getCurrentWeatherData(String query) async
  {
    var url = this.currentWeatherApi + "$query&" + units + "appid=$apiId";
    var response = await http.get(Uri.parse(url));

    setState(() {
      this.currentWeatherData = json.decode(response.body);
    });
  }

  Future<List> getForecastWeatherData(String query) async
  {
    var url = this.forecastApi + "$query&" + units + "appid=$apiId";
    var response = await http.get(Uri.parse(url));
    var jsonResponse = json.decode(response.body);

    setState(() {
      this.forcastDataList = jsonResponse['list'];
    });
  }

  Future getMyLocation() async
  {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
    .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
    .then((Position position)
    {
      setState(()
      {
        this.currentWeatherData = null;
        this.forcastDataList = null;
      });

      var latLon = "lat=${position.latitude.toStringAsFixed(2)}&lon=${position.longitude.toStringAsFixed(2)}";

      this.getCurrentWeatherData(latLon);
      this.getForecastWeatherData(latLon);
    })
    .catchError((e) {
      print("Error in location: $e");
    });
  }

  String  getWindDirection(degree)
  {
    if (degree>337.5) return 'Northerly';
    if (degree>292.5) return 'North Westerly';
    if (degree>247.5) return 'Westerly';
    if (degree>202.5) return 'South Westerly';
    if (degree>157.5) return 'Southerly';
    if (degree>122.5) return 'South Easterly';
    if (degree>67.5) return 'Easterly';
    if (degree>22.5) return 'North Easterly';
    return 'Northerly';
  }

  String getTime(int time)
  {
    var now = DateTime.fromMillisecondsSinceEpoch(time * 1000);
    String hourString = (now.hour.toString().length <= 1 ? "0" : '') + now.hour.toString();
    String minuteString = (now.minute.toString().length <= 1 ? "0" : '') + now.minute.toString();

    return("$hourString:$minuteString");
  }

  IconData getWeatherIcon(String iconName)
  {
    switch (iconName)
    {
      // day icons
      case '01d': return FontAwesomeIcons.solidSun;                    // clear sky
      case '02d': return FontAwesomeIcons.cloudSun;                    // few clouds
      case '03d': return FontAwesomeIcons.cloud;                       // scattered clouds
      case '04d': return FontAwesomeIcons.cloudMeatball;               // broken clouds
      case '09d': return FontAwesomeIcons.cloudShowersHeavy;          //  shower rain
      case '10d': return FontAwesomeIcons.cloudSunRain;                // rain
      case '11d': return FontAwesomeIcons.bolt;                       //  thunderstorm
      case '13d': return FontAwesomeIcons.snowflake;                  //  snow
      case '50d': return FontAwesomeIcons.smog;                       //  mist

      // night icons
      case '01n': return FontAwesomeIcons.solidMoon;              // clear sky
      case '02n': return FontAwesomeIcons.cloudMoon;             // few clouds
      case '03n': return FontAwesomeIcons.cloud;                 // scattered clouds
      case '04n': return FontAwesomeIcons.cloudMeatball;        //  broken clouds
      case '09n': return FontAwesomeIcons.cloudShowersHeavy;    //  shower rain
      case '10n': return FontAwesomeIcons.cloudMoonRain;        //  rain
      case '11n': return FontAwesomeIcons.bolt;                 //  thunderstorm
      case '13n': return FontAwesomeIcons.snowflake;           //  snow
      case '50n': return FontAwesomeIcons.smog;                //  mist
      default: print("iconName: $iconName");
    }
  }

  Widget iconWithText(IconData iconData, double space, String text) =>
  Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Icon(
        iconData,
        size: 12,
      ),

      Container(width: space,),

      Text(
        text,
        style: TextStyle(
          fontSize: 14,
        ),
      ),

    ],
  );

  Widget weatherDetailsItem(String title, IconData iconData, String text) =>
  Expanded(
    child: Card(
      color: Colors.transparent,
      child: Container(
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Icon(iconData),
            ),


            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),

          ],
        ),
      ),
    ),
  );

  Widget forcastWeatherItem(date, humidity, iconName, description, minTemp, maxTemp) =>
  Container(
    width: double.infinity,
    padding: EdgeInsets.all(8),
    child: Row(
      children: <Widget>[

        // date start
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              date,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        // date end

        // humidity start
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.center,
            child: iconWithText(
              FontAwesomeIcons.tint,
              0,
              "$humidity%"
            )
          ),
        ),
        // humidity end

        // description start
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.center,
            child: Icon(
              this.getWeatherIcon(iconName),
            ),
          ),
        ),
        // description end

        // weather icon start
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              description,
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        // weather icon end

        // temp min & max start
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              "${minTemp.toStringAsFixed(0)}°/${maxTemp.toStringAsFixed(0)}°",
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        // temp min & max end

      ],
    ),
  );

  String getWeekName(int week)
  {
    switch (week) {
      case 1: return "MON";
      case 2: return "TUS";
      case 3: return "WEN";
      case 4: return "THU";
      case 5: return "FRI";
      case 6: return "SAT";
      case 7: return "SUN";
    }
  }

  Widget forcastList()
  {
    List<Widget> forcastWeatherRow = List();

    for (var i = 0; i < forcastDataList.length; i++) {
      var now = DateTime.fromMillisecondsSinceEpoch(this.forcastDataList[i]['dt'] * 1000);
      String date = "${this.getWeekName(now.weekday)}\n";
      date += "${now.day}/";
      date += "${now.month}";
      forcastWeatherRow.add(forcastWeatherItem(
        date,
        this.forcastDataList[i]['main']['humidity'],
        this.forcastDataList[i]['weather'][0]['icon'],
        this.forcastDataList[i]['weather'][0]['description'],
        this.forcastDataList[i]['main']['temp_min'],
        this.forcastDataList[i]['main']['temp_max'],
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: forcastWeatherRow,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: apiId == null || apiId.isEmpty?
        Center(
          child: Text("Please Insert your API KEY"),
        ) :
        currentWeatherData == null?
        Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ) :
        SafeArea(
          child: Stack(
            children: <Widget>[

              SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(left: 8, top: 48, right: 8, bottom: 8),
                  child: Column(
                    children: <Widget>[

                      // current temp details start
                      Stack(
                        alignment: Alignment.topCenter,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 64),
                            child: Card(
                              color: Colors.transparent,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.only(left: 8, top: 56, right: 8, bottom: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[

                                    // temp current, max, min start
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[

                                        // temp current start
                                        Text(
                                          "${this.currentWeatherData['main']['temp']}°",
                                          style: TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.w200,
                                          ),
                                        ),
                                        // temp current end

                                        // temp max & min start
                                        Container(
                                          padding: EdgeInsets.only(left: 8),
                                          child: Row(
                                            children: <Widget>[

                                              iconWithText(
                                                FontAwesomeIcons.angleDoubleUp,
                                                0,
                                                "${this.currentWeatherData['main']['temp_max']}°"
                                              ),

                                              Container(width: 8,),

                                              iconWithText(
                                                FontAwesomeIcons.angleDoubleDown,
                                                0,
                                                "${this.currentWeatherData['main']['temp_min']}°"
                                              ),
                                            ],
                                          ),
                                        ),
                                        // temp max & min end

                                      ],
                                    ),
                                    // temp current, max, min end

                                    // weather description, temp, humidity, date time start
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: <Widget>[

                                        // weather description start
                                        Text(
                                          this.currentWeatherData['weather'][0]['description'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        // weather description end

                                        Container(height: 8,),

                                        // temp & humidity start
                                        Row(
                                          children: <Widget>[

                                            iconWithText(
                                              FontAwesomeIcons.tshirt,
                                              5,
                                              "${this.currentWeatherData['main']['feels_like']}°"
                                            ),

                                            Container(width: 8,),

                                            iconWithText(
                                              FontAwesomeIcons.tint,
                                              0,
                                              "${this.currentWeatherData['main']['humidity']}%"
                                            ),
                                          ],
                                        ),
                                        // temp & humidity end

                                        Container(height: 8,),

                                        // weather description start
                                        Text(
                                          this.getTime(this.currentWeatherData['dt']) + " update",
                                          softWrap: true,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        // weather description end

                                      ],
                                    ),
                                    // weather description, temp, humidity, date time end

                                  ],
                                ),
                              ),
                            ),
                          ),

                          // sun icon start
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)
                            ),
                            elevation: 0,
                            color: Colors.blue,
                            child: Container(
                              height: 128,
                              width: 128,
                              child: Icon(
                                this.getWeatherIcon(this.currentWeatherData['weather'][0]['icon']),
                                size: 64,
                              ),
                            ),
                          ),
                          // sun icon start
                        ],
                      ),
                      // current temp details end

                      // forcast weather start
                      forcastDataList == null?
                      Container() :
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[

                            Text(
                              "Future",
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                              ),
                            ),

                            // weather forcast list start
                            Card(
                              color: Colors.transparent,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: forcastList(),
                              )
                            ),
                            // weather forcast list end

                          ],
                        ),
                      ),
                      // forcast weather end

                      Container(height: 32,),

                      // Sunrise & Sunset start
                      Container(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[

                            Text(
                              "Sunrise & Sunset",
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                              ),
                            ),

                            Card(
                              color: Colors.transparent,
                              child: Container(
                                height: 100,
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[

                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[

                                        // Sunrise start
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[

                                            Icon(
                                              FontAwesomeIcons.sun
                                            ),

                                            Container(width: 16,),

                                            Text(
                                              this.getTime(this.currentWeatherData['sys']['sunrise']),
                                              style: TextStyle(fontSize: 24),
                                            ),

                                          ],
                                        ),
                                        // Sunrise end

                                        Container(height: 8,),

                                        // Sunset start
                                        Row(
                                          children: <Widget>[

                                            Icon(
                                              FontAwesomeIcons.moon
                                            ),

                                            Container(width: 16,),

                                            Text(
                                              this.getTime(this.currentWeatherData['sys']['sunset']),
                                              style: TextStyle(fontSize: 24),
                                            )

                                          ],
                                        ),
                                        // Sunset end

                                      ],
                                    ),


                                    Expanded(
                                      child: Stack(
                                        alignment:  Alignment.bottomCenter,
                                        children: <Widget>[

                                          Container(
                                            height: double.infinity,
                                            width: double.infinity,
                                            padding: EdgeInsets.only(left: 10, right: 10 , bottom: 16),
                                            child: Image.asset(
                                              'assets/sunrisebg.png',
                                            ),
                                          ),

                                          Container(
                                            height: 1,
                                            width: double.infinity,
                                            color: Colors.grey,
                                            margin: EdgeInsets.symmetric(horizontal: 16),
                                          ),

                                          Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(horizontal: 30),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[

                                                Icon(
                                                  FontAwesomeIcons.solidSun,
                                                ),


                                                Icon(
                                                  FontAwesomeIcons.solidMoon,
                                                ),

                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Sunrise & Sunset end

                      Container(height: 32,),

                      // wind details start
                      Container(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[

                            Text(
                              "Wind",
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                              ),
                            ),

                            Card(
                              color: Colors.transparent,
                              child: Container(
                                height: 100,
                                padding: EdgeInsets.all(24),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[

                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                      child: Icon(
                                        FontAwesomeIcons.wind,
                                        size: 48,
                                      ),
                                    ),

                                    Container(
                                      height: double.infinity,
                                      width: 1,
                                      color: Colors.white30,
                                      margin: EdgeInsets.symmetric(horizontal: 8),
                                    ),

                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        child: Column(
                                          children: <Widget>[

                                            // wind direction start
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[

                                                  Text(
                                                    "Direction",
                                                    style: TextStyle(fontWeight: FontWeight.w300),
                                                  ),

                                                  Text(
                                                    this.getWindDirection(this.currentWeatherData['wind']['deg']),
                                                  )

                                                ],
                                              ),
                                            ),
                                            // wind direction end

                                            // wind speed start
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[

                                                  Text(
                                                    "Speed",
                                                    style: TextStyle(fontWeight: FontWeight.w300),
                                                  ),

                                                  Text(
                                                    (this.currentWeatherData['wind']['speed'] * 2.23694).toStringAsFixed(2),
                                                  )

                                                ],
                                              ),
                                            ),
                                            // wind speed end

                                          ],
                                        ),
                                      ),
                                    ),


                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // wind details end

                      Container(height: 32,),

                      // details pressure, visibility & humidity start
                      Container(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[

                            Text(
                              "Details",
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                              ),
                            ),

                            Row(
                              children: <Widget>[

                                weatherDetailsItem(
                                  "Pressure",
                                  FontAwesomeIcons.tachometerAlt,
                                  "${this.currentWeatherData['main']['pressure']}",
                                ),

                                weatherDetailsItem(
                                  "Visibility",
                                  FontAwesomeIcons.eye,
                                  "${this.currentWeatherData['visibility']}m",
                                ),

                                weatherDetailsItem(
                                  "Humidity",
                                  FontAwesomeIcons.tint,
                                  "${this.currentWeatherData['main']['humidity']}%",
                                ),

                              ],
                            ),
                          ],
                        ),
                      ),
                      // details pressure, visibility & humidity end

                    ],
                  ),
                ),
              ),

              // app bar start
              Container(
                color: Colors.black12,
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[

                    Text(
                      this.currentWeatherData['name'],
                      style: TextStyle(fontSize: 18),
                    ),

                    InkWell(
                      child: Icon(Icons.location_searching),
                      onTap: getMyLocation,
                    )


                  ],
                ),
              ),
              // app bar endr

            ],
          ),
        ),
    );
  }
}