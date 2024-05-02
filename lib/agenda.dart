import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

class Agenda extends StatefulWidget {
  const Agenda({Key? key}) : super(key: key);

  @override
  State<Agenda> createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};
  List<dynamic> _agendamientos = [];

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _fetchAgendamientos();
  }

  Future<void> _fetchAgendamientos() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:8081/api/agendamientos'));
      if (response.statusCode == 200) {
        final List<dynamic> agendamientos = json.decode(response.body);
        setState(() {
          _agendamientos = agendamientos;
        });
      } else {
        throw Exception('Error al obtener los agendamientos');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> _mostrarModalServicios(int idAgendamiento) async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost:8081/api/agendamientos/$idAgendamiento'));
      if (response.statusCode == 200) {
        final detallesAgendamiento =
            json.decode(response.body)['detalleAgendamiento'];
        final responseServicios =
            await http.get(Uri.parse('http://localhost:8081/api/servicio'));
        if (responseServicios.statusCode == 200) {
          final servicios = json.decode(responseServicios.body);
          final detallesActualizados = detallesAgendamiento.map((detalle) {
            final servicio = servicios.firstWhere(
                (servicio) =>
                    servicio['idServicio'] == detalle['servicios_idServicio'],
                orElse: () => null);
            return {
              ...detalle,
              'nombreServicio': servicio != null
                  ? servicio['nombreServicio']
                  : 'Servicio no encontrado',
            };
          }).toList();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Servicios'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: detallesActualizados.map<Widget>((detalle) {
                    return Text('${detalle['nombreServicio']}');
                  }).toList(),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cerrar'),
                  ),
                ],
              );
            },
          );
        } else {
          throw Exception('Error al obtener los servicios');
        }
      } else {
        throw Exception('Error al obtener los detalles del agendamiento');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Map<DateTime, List<dynamic>> _parseEvents(List<dynamic> agendamientos) {
    final Map<DateTime, List<dynamic>> events = {};
    for (final agendamiento in agendamientos) {
      final DateTime fecha = DateTime.parse(agendamiento['fecha']);
      if (events.containsKey(fecha)) {
        events[fecha]!.add(agendamiento);
      } else {
        events[fecha] = [agendamiento];
      }
    }
    return events;
  }

  bool _tieneEventos(DateTime day) {
    return _events.containsKey(day) && _events[day]!.isNotEmpty;
  }

  String horaOf12Hours(int hora) {
    if (hora == 0) {
      return '12';
    } else if (hora > 12) {
      return (hora - 12).toString();
    } else {
      return hora.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final citasDeHoy = _agendamientos.where((cita) {
      final citaFecha = DateTime.parse(cita['fecha']);
      return citaFecha.year == _selectedDay.year &&
          citaFecha.month == _selectedDay.month &&
          citaFecha.day == _selectedDay.day;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            eventLoader: (day) {
              return _events[day] ?? [];
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                return Stack(
                  children: [
                    if (_tieneEventos(date))
                      const Positioned(
                        right: 1,
                        bottom: 1,
                        child: Icon(
                          Icons.event,
                          size: 16,
                          color: Colors.red,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Citas del día:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: citasDeHoy.length,
              itemBuilder: (context, index) {
                final agendamiento = citasDeHoy[index];
                final placa = agendamiento['vehiculos_placa'];
                final fechaString = agendamiento['fecha'];
                final fecha = DateTime.parse(fechaString);
                final hora = fecha.hour;
                final minutos = fecha.minute;
                final amPm = hora >= 12 ? 'PM' : 'AM';
                final horaFormateada =
                    '${horaOf12Hours(hora)}:${minutos.toString().padLeft(2, '0')} $amPm';
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Placa del vehículo: $placa',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hora: $horaFormateada',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            _mostrarModalServicios(
                                agendamiento['idAgendamiento']);
                          },
                          child: const Text('Más Información'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
