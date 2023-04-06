import 'package:flutter/material.dart';
import 'package:lora_monitor/infraestructure/dashboard_repo.dart';
import 'package:lora_monitor/infraestructure/user_limits_repo.dart';
import 'core/size_config.dart';

enum NavigationState {
  home,
  measures,
  settings,
}

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

  @override
  void initState() {
    super.initState();
  }

  void changeTitle(String title) {
    setState(() {
      widget.title = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    Widget currentPage;

    switch (navState) {
      case NavigationState.home:
        changeTitle("Mediciones más recientes");
        currentPage = const DashboardStream();
        break;
      case NavigationState.settings:
        changeTitle("Configuración de alertas");
        currentPage = UserLimitsRepo();
        break;
      case NavigationState.measures:
        changeTitle("Recolección de datos");
        currentPage = const Text("home");
        //currentPage = const APSensorRepo();
        break;
    }

    return Scaffold(
      appBar: AppBar(
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
