import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:crm_app/features/shared/shared.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';

class AgendaScreen extends StatelessWidget {
  const AgendaScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        title: const Text('Calendario'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded))
        ],
      ),
      body: const _AgendaView(),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Crear evento'),  
        icon: const Icon(Icons.add),
        onPressed: () {
          context.push('/event/no-id');
        },
      ),
    );
  }
}

class _AgendaView extends ConsumerStatefulWidget {
  const _AgendaView();

  @override
  _AgendaViewState createState() => _AgendaViewState();
}

class Agenda {
  final String name;
  final String nameCompany;
  final String comment;
  final String namePosition;
  final String price;

  Agenda(this.name, this.nameCompany, this.comment, this.namePosition, this.price);
}

class _AgendaViewState extends ConsumerState {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if ((scrollController.position.pixels + 400) >=
          scrollController.position.maxScrollExtent) {
        //ref.read(productsProvider.notifier).loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];
    final DateTime today = DateTime.now();
    final DateTime startTime = DateTime(today.year, today.month, today.day, 9);
    final DateTime endTime = startTime.add(const Duration(hours: 2));
    meetings.add(Meeting(
        'Conference', startTime, endTime, const Color(0xFF0F8644), false));
    return meetings;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Cambia este valor al número de pestañas que desees
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'POR MES'),
              Tab(text: 'POR DÍA'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildCalendarView(CalendarView.month),
                _buildCalendarView(CalendarView.day),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView(CalendarView view) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: SfCalendar(
        view: view,
        dataSource: MeetingDataSource(_getDataSource()),
        monthViewSettings: const MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        ), 
      ),
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getMeetingData(index).from;
  }

  @override
  DateTime getEndTime(int index) {
    return _getMeetingData(index).to;
  }

  @override
  String getSubject(int index) {
    return _getMeetingData(index).eventName;
  }

  @override
  Color getColor(int index) {
    return _getMeetingData(index).background;
  }

  @override
  bool isAllDay(int index) {
    return _getMeetingData(index).isAllDay;
  }

  Meeting _getMeetingData(int index) {
    final dynamic meeting = appointments![index];
    late final Meeting meetingData;
    if (meeting is Meeting) {
      meetingData = meeting;
    }

    return meetingData;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
