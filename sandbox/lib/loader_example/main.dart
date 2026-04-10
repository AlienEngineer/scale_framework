import 'package:flutter/material.dart';
import 'package:scale_framework/scale_framework.dart';

import 'module.dart';
import 'widget.dart';

void main() {
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({super.key});

    // This widget is the root of your application.
    @override
    Widget build(BuildContext context) {
        Stream stream = Stream.periodic(const Duration(milliseconds: 500), (i) => i);

        return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
            home: ModuleSetup(
            featureModules: [TestFeatureModule(1)],
            child: RebuilderWidget(stream: stream),
        ),
        );
    }
}

class RebuilderWidget extends StatefulWidget {
    Stream stream;
    RebuilderWidget({super.key, required this.stream});

    @override
    State<RebuilderWidget> createState() => _RebuilderWidgetState();
}

class _RebuilderWidgetState extends State<RebuilderWidget> {

    bool _toggle = false;
    List<dynamic> _widgets = [];

    initState() {
        super.initState();
    /*    widget.stream.listen((event) {
            /*
            setState(() {
                _toggle = !_toggle;
            });
            */
        });*/
    }

    @override
    Widget build(BuildContext context) {
        print('Rebuilding Scaffold');
        return Scaffold(
            body: doMyStuff(),
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                    setState(() { 
                        _toggle = !_toggle;
                    });
                },
                child: Icon(Icons.refresh),
            ),
        );
    }

    Widget doMyStuff() {
        if (_toggle) {
            return ProblematicWidget(_widgets, widget.stream, key: widget.key);
            return widget;
        } else {
            print("disposed was called");
            return Text("all is clear here");
        }
    }
}


class ProblematicWidget extends StatefulWidget {
    List<dynamic> widgets;
    Stream stream;
    ProblematicWidget( this.widgets, this.stream, {super.key});

    @override
    State<ProblematicWidget> createState() {
        var state =  _ProblematicWidgetState();
        widgets.add(state);
        return state;
    } 
}

class _ProblematicWidgetState extends State<ProblematicWidget> {
    bool _isAnimated = true;
    Duration animDuration = const Duration(milliseconds: 250);
    int _counter = 0;

    @override
    void initState() {
        super.initState();
        refreshBars();

        widget.stream.listen((event) {
            print("counter: $_counter stream event: $event, isAnimated: $_isAnimated ${this.hashCode} ${DateTime.now()}");
        });
    }

    @override
    void dispose() {
        print("I'm all disposed! ${this.hashCode} ${DateTime.now()}");
        if (_isAnimated) {
            _isAnimated = false;
        }
        super.dispose();
    }

    Future<dynamic> refreshBars() async {

        setState(() {
            print("I don't like to be here!");
            _counter++;
        });

        await Future<dynamic>.delayed(
            animDuration + const Duration(milliseconds: 70),
        );

        print("after dekay, isAnimated: $_isAnimated ${this.hashCode} ${DateTime.now()}");

        if ( _isAnimated) {
            await refreshBars();
        }
    }

    @override
    Widget build(BuildContext context) {
        return Text(_counter.toString());
    }
}


class MyWidget extends StatelessWidget {
    const MyWidget({super.key});

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: Center(child: const BffDataTestWidget()),
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                    context.refresh<BffData>({'id': 1});
                },
                child: Icon(Icons.cloud_download),
            ),
        );
    }
}
