//import 'dart:ffi';
//import 'dart:js';

import 'package:flutter/material.dart';

const routeHome = '/';
const routeSettings = '/settings';
const routePrefixDeviceSetup = '/setup/';
const routeDeviceSetupStart = '/setup/$routeDeviceSetupStartPage';
const routeDeviceSetupStartPage = 'find_devices';
const routeDeviceSetupSelectDevicePage = 'select_device';
const routeDeviceSetupConnectingPage = 'connecting';
const routeDeviceSetupFinishedPage = 'finished';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.amberAccent[500],
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.amberAccent[500],
        ),
      ),
      onGenerateRoute: (settings) {
        //gerando rotas de navegação
        late Widget page;
        if (settings.name == routeHome) {
          page = HomeScreen();
        } else if (settings.name == routeSettings) {
          page = SettingsScreen();
        } else if (settings.name!.startsWith(routePrefixDeviceSetup)) {
          final subRoute =
              settings.name!.substring(routePrefixDeviceSetup.length);
          page = SetupFlow(
            setupPageRoute: subRoute,
          );
        } else {
          throw Exception('Rota Desconhecida: ${settings.name}');
        }

        return MaterialPageRoute<dynamic>(
          builder: (context) {
            return page;
          },
          settings: settings,
        );
      },
      debugShowCheckedModeBanner: false,
    ),
  );
}

@immutable
class SetupFlow extends StatefulWidget {
  static SetupFlowState of(BuildContext context) {
    return context.findAncestorStateOfType<SetupFlowState>()!;
  }

  const SetupFlow({
    Key? key,
    required this.setupPageRoute,
  }) : super(key: key);

  final String setupPageRoute;

  @override
  SetupFlowState createState() => SetupFlowState();
}

class SetupFlowState extends State<SetupFlow> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
  }

  void _onDiscoveryComplete() {
    _navigatorKey.currentState!.pushNamed(routeDeviceSetupSelectDevicePage);
  }

  void _onDeviceSelected(String deviceId) {
    _navigatorKey.currentState!.pushNamed(routeDeviceSetupConnectingPage);
  }

  void _onConnectionEstablished() {
    _navigatorKey.currentState!.pushNamed(routeDeviceSetupFinishedPage);
  }

  Future<void> _onExitPressed() async {
    final isConfirmed = await _isExitDesired();

    if (isConfirmed && mounted) {
      _exitSetup();
    }
  }

  Future<bool> _isExitDesired() async {
    return await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Você tem certeza que deseja sair?'),
                content: Text(
                    'Se você sair da configuração do dispositivo, seus dados serão perdidos.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Text('Sair'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text('Continuar'),
                  ),
                ],
              );
            }) ??
        false;
  }

  void _exitSetup() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _isExitDesired,
      child: Scaffold(
        appBar: _buildFlowAppBar(),
        body: Navigator(
          key: _navigatorKey,
          initialRoute: widget.setupPageRoute,
          onGenerateRoute: _onGenerateRoute,
        ),
      ),
    );
  }

  Route _onGenerateRoute(RouteSettings settings) {
    late Widget page;
    switch (settings.name) {
      case routeDeviceSetupStartPage:
        page = WaitingPage(
          message: 'Localizando a versão mais proxima ...',
          onWaitComplete: _onDiscoveryComplete,
        );
        break;
      case routeDeviceSetupSelectDevicePage:
        page = SelectDevicePage(
          onDeviceSelected: _onDeviceSelected,
        );
        break;
      case routeDeviceSetupConnectingPage:
        page = WaitingPage(
          message: 'Conectando...',
          onWaitComplete: _onConnectionEstablished,
        );
        break;
      case routeDeviceSetupFinishedPage:
        page = FinishedPage(
          onFinishPressed: _exitSetup,
        );
        break;
    }

    return MaterialPageRoute<dynamic>(
      builder: (context) {
        return page;
      },
      settings: settings,
    );
  }

  PreferredSizeWidget _buildFlowAppBar() {
    return AppBar(
      leading: IconButton(
        onPressed: _onExitPressed,
        icon: Icon(Icons.chevron_left),
      ),
      title: Text('Detectando...'),
    );
  }
}

class SelectDevicePage extends StatelessWidget {
  const SelectDevicePage({
    Key? key,
    required this.onDeviceSelected,
  }) : super(key: key);

  final void Function(String deviceId) onDeviceSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selecionar a versão mais proxima:',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith((states) {
                      return const Color(0xFF222222);
                    }),
                  ),
                  onPressed: () {
                    onDeviceSelected('22n483nk5834');
                  },
                  child: Text(
                    'AndyBug 22n483nk5834',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WaitingPage extends StatefulWidget {
  const WaitingPage({
    Key? key,
    required this.message,
    required this.onWaitComplete,
  }) : super(key: key);

  final String message;
  final VoidCallback onWaitComplete;

  @override
  _WaitingPageState createState() => _WaitingPageState();
}

class _WaitingPageState extends State<WaitingPage> {
  @override
  void initState() {
    super.initState();
    _startWaiting();
  }

  Future<void> _startWaiting() async {
    await Future<dynamic>.delayed(const Duration(seconds: 3));

    if (mounted) {
      widget.onWaitComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 32),
              Text(widget.message),
            ],
          ),
        ),
      ),
    );
  }
}

class FinishedPage extends StatelessWidget {
  const FinishedPage({
    Key? key,
    required this.onFinishPressed,
  }) : super(key: key);

  final VoidCallback onFinishPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF222222),
                ),
                child: Center(
                  child: Icon(
                    Icons.android,
                    size: 175,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 32),
              Text(
                'Bugdroid adicionado!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.resolveWith((states) {
                    return const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12);
                  }),
                  backgroundColor: MaterialStateColor.resolveWith((states) {
                    return const Color(0xFF222222);
                  }),
                  shape: MaterialStateProperty.resolveWith((states) {
                    return StadiumBorder();
                  }),
                ),
                onPressed: onFinishPressed,
                child: Text(
                  'Finalizar',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@immutable
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF222222),
                ),
                child: Center(
                  child: Icon(
                    Icons.android,
                    size: 175,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
              ),
              SizedBox(height: 32),
              Text(
                'Adicionar a versão do seu dispositivo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(routeDeviceSetupStart);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Configuração de dispositivo'),
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            Navigator.pushNamed(context, routeSettings);
          },
        ),
      ],
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(8, (index) {
            return Container(
              width: double.infinity,
              height: 54,
              margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF222222),
              ),
            );
          }),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Settings'),
    );
  }
}
