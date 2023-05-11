import 'package:flutter/material.dart';
import 'package:lora_monitor/infraestructure/dashboard/dashboard_stream.dart';
import 'package:lora_monitor/infraestructure/settings/user_limits_stream.dart';
import 'package:lora_monitor/presentation/ap_sensor/ap_sensor_repo.dart';
import 'package:lora_monitor/presentation/chart/chart_view.dart';
import 'package:lora_monitor/presentation/chart/connection_stream.dart';
import 'package:lora_monitor/presentation/core/text.dart';
import 'core/size_config.dart';

enum NavigationState {
  home,
  measures,
  settings,
}

enum HomeState { dashboard, chart }

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlantMonitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(),
    );
  }
}

// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  MyHomePage({
    super.key,
  });
  String title = "";
  String sensorName = "sensorOne";

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  NavigationState navState = NavigationState.home;
  HomeState homeState = HomeState.dashboard;

  @override
  void initState() {
    super.initState();
  }

  void changeTitle(String title) {
    setState(() {
      widget.title = title;
    });
  }

  void changePage(HomeState page, String sensorName) {
    setState(() {
      widget.sensorName = sensorName;
      homeState = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    Widget currentPage;

    switch (navState) {
      case NavigationState.home:
        switch (homeState) {
          case HomeState.dashboard:
            changeTitle("Mediciones más recientes");
            currentPage = DashboardStream(changePage: changePage);
            break;
          case HomeState.chart:
            changeTitle("Gráficos de mediciones");
            currentPage = ConnectionStream(
                url: 'http://www.google.com',
                connected: ChartView(sensorName: widget.sensorName),
                disconnected: getTitleText("Conectese a internet", false));
            break;
        }
        break;
      case NavigationState.settings:
        changeTitle("Configuración de alertas");
        currentPage = UserLimitsStream();
        break;
      case NavigationState.measures:
        changeTitle("Recolección de datos");
        currentPage = const APSensorRepo();
        break;
    }

    return Scaffold(
      appBar: homeState != HomeState.chart
          ? AppBar(
              title: Text(widget.title),
            )
          : AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => changePage(HomeState.dashboard, ""),
              ),
              title: Text(widget.title),
            ),
      body: currentPage,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: navState.index,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.analytics), label: "Mediciones"),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box), label: "Recolección"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active), label: "Alertas"),
        ],
        onTap: (pagina) {
          setState(() {
            navState = NavigationState.values[pagina];
            homeState = HomeState.dashboard;
          });
        },
      ),
    );
  }
}
