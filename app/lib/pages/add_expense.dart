import 'package:flutter/material.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _participantController = TextEditingController();
  final List<String> _participants = [];
  bool _addToExistingGroup = false;
  String _selectedCurrency = 'Euro';

  /// Speichert die Ausgabe
  void _saveExpense() {
    final String title = _titleController.text.trim();

    if (title.isEmpty || _participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter title and add participants')),
      );
      return;
    }

    // Dummy logic for saving expense
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Expense "$title" added with ${_participants.length} participants in $_selectedCurrency currency.')),
    );

    Navigator.pop(context);
  }

  /// Fügt einen Teilnehmer zur Liste hinzu
  void _addParticipant() {
    final String participant = _participantController.text.trim();

    if (participant.isNotEmpty) {
      setState(() {
        _participants.add(participant);
        _participantController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 📝 Titel der Ausgabe
            const Text(
              'Titel',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Expense Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 24),

            /// 👥 Teilnehmer hinzufügen
            const Text(
              'Teilnehmer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _participantController,
                    decoration: const InputDecoration(
                      labelText: 'Add Participant',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_add),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addParticipant,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                itemCount: _participants.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(_participants[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle),
                    onPressed: () {
                      setState(() {
                        _participants.removeAt(index);
                      });
                    },
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            /// 🏷️ Zu bestehender Gruppe hinzufügen?
            CheckboxListTile(
              title: const Text('Zu bestehender Gruppe hinzufügen?'),
              value: _addToExistingGroup,
              onChanged: (bool? value) {
                setState(() {
                  _addToExistingGroup = value ?? false;
                });
              },
            ),
            const SizedBox(height: 24),

            /// 💱 Währungsauswahl
            const Text(
              'Währung',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              items: const [
                DropdownMenuItem(value: 'Euro', child: Text('Euro (€)')),
                DropdownMenuItem(value: 'USD', child: Text('US Dollar (\$)')),
                DropdownMenuItem(value: 'GBP', child: Text('Pfund (£)')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value ?? 'Euro';
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            /// 💾 Speichern-Button
            ElevatedButton(
              onPressed: _saveExpense,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Save Expense'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _participantController.dispose();
    super.dispose();
  }
}
