import 'package:flutter/material.dart';
import 'package:lora_monitor/infraestructure/dashboard_stream.dart';
import 'package:lora_monitor/infraestructure/settings/user_limits_stream.dart';
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
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('es', 'ES'),
      ],
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

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  NavigationState navState = NavigationState.home;
  HomeState homState = HomeState.dashboard;

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
      print(sensorName);
      homState = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    Widget currentPage;

    switch (navState) {
      case NavigationState.home:
        switch (homState) {
          case HomeState.dashboard:
            changeTitle("Mediciones más recientes");
            currentPage = DashboardStream(changePage: changePage);
            break;
          case HomeState.chart:
            changeTitle("Gráficos de mediciones");
            currentPage = const Text("chart");
            break;
        }
        break;
      case NavigationState.settings:
        changeTitle("Configuración de alertas");
        currentPage = UserLimitsStream();
        break;
      case NavigationState.measures:
        changeTitle("Recolección de datos");
        currentPage = const Text("home");
        //currentPage = const APSensorRepo();
        break;
    }

    return Scaffold(
      appBar: homState != HomeState.chart
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
          });
        },
      ),
    );
  }
}
