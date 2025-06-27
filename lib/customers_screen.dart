// customers_screen.dart
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart'; // For date formatting

// Customer Data Model
class Customer {
  String id;
  String firstName;
  String? middleName;
  String lastName;
  String email;
  String phone;
  String address;
  String gender;
  DateTime birthDate;

  Customer({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.gender,
    required this.birthDate,
  });

  // Convert Customer object to JSON for GetStorage
  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'middleName': middleName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'address': address,
    'gender': gender,
    'birthDate': birthDate.toIso8601String(), // Store DateTime as ISO 8601 string
  };

  // Create Customer object from JSON
  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json['id'] as String,
    firstName: json['firstName'] as String,
    middleName: json['middleName'] as String?,
    lastName: json['lastName'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    address: json['address'] as String,
    gender: json['gender'] as String,
    birthDate: DateTime.parse(json['birthDate'] as String),
  );

  // Helper to calculate age from birth date
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final GetStorage _box = GetStorage();
  List<Customer> _customers = [];
  int _nextCustomerId = 1; // For auto-incremental ID

  @override
  void initState() {
    super.initState();
    _loadCustomers(); // Load customers when the screen initializes
  }

  // Load customers and next ID from local storage
  void _loadCustomers() {
    final List<dynamic>? storedCustomersJson = _box.read('customers');
    if (storedCustomersJson != null) {
      setState(() {
        _customers = storedCustomersJson.map((json) => Customer.fromJson(json)).toList();
        // Determine the next available ID by finding the max existing ID and adding 1
        _nextCustomerId = _customers.isEmpty
            ? 1
            : (_customers
            .map((c) => int.tryParse(c.id.replaceFirst('CUST', '')) ?? 0)
            .reduce((a, b) => a > b ? a : b) +
            1);
      });
    }
  }

  // Save customers to local storage
  void _saveCustomers() {
    _box.write('customers', _customers.map((customer) => customer.toJson()).toList());
  }

  // Generate a new customer ID
  String _generateCustomerId() {
    final String id = 'CUST${_nextCustomerId.toString().padLeft(4, '0')}';
    _nextCustomerId++;
    return id;
  }

  // Show the form for adding/editing customers using the new CustomerFormBottomSheet
  void _showCustomerFormBottomSheet({Customer? customerToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return CustomerFormBottomSheet(
          customerToEdit: customerToEdit,
          onSubmitted: (customer) {
            if (customerToEdit == null) {
              // Add new customer
              setState(() {
                _customers.add(customer.copyWith(id: _generateCustomerId())); // Ensure new ID for new customer
              });
            } else {
              // Edit existing customer
              setState(() {
                final index = _customers.indexWhere((c) => c.id == customer.id);
                if (index != -1) {
                  _customers[index] = customer;
                }
              });
            }
            _saveCustomers(); // Save changes to local storage
            Navigator.pop(context); // Close the bottom sheet
          },
        );
      },
    );
  }

  // Delete customer function
  void _deleteCustomer(String customerId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this customer?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _customers.removeWhere((customer) => customer.id == customerId);
                  _saveCustomers(); // Save changes
                });
                Navigator.of(context).pop(); // Dismiss dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Customer deleted successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Red for delete action
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define colors for consistent styling
    final Color primaryGreen = Theme.of(context).primaryColor;
    final Color accentBlue = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Customers',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryGreen,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: () => _showCustomerFormBottomSheet(), // Open register form
                  icon: const Icon(Icons.person_add),
                  label: const Text('Register Customer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, // Allows horizontal scrolling for wide tables
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical, // Allows vertical scrolling for tall tables
                  child: DataTable(
                    columnSpacing: 20.0, // Adjust spacing between columns
                    dataRowMinHeight: 50.0,
                    dataRowMaxHeight: 60.0,
                    headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) => primaryGreen.withOpacity(0.1)),
                    border: TableBorder.all(
                      color: Colors.grey.shade300,
                      width: 1,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    columns: const <DataColumn>[
                      DataColumn(label: Text('Customer ID', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Address', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Gender', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Age', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: _customers.map((customer) {
                      return DataRow(
                        cells: <DataCell>[
                          DataCell(Text(customer.id)),
                          DataCell(Text('${customer.firstName} ${customer.middleName ?? ''} ${customer.lastName}')),
                          DataCell(Text(customer.phone)),
                          DataCell(Text(customer.email)),
                          DataCell(Text(customer.address)),
                          DataCell(Text(customer.gender)),
                          DataCell(Text(customer.age.toString())),
                          DataCell(Row(
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.edit, color: accentBlue),
                                onPressed: () => _showCustomerFormBottomSheet(customerToEdit: customer),
                                tooltip: 'Edit Customer',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteCustomer(customer.id),
                                tooltip: 'Delete Customer',
                              ),
                            ],
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// New Stateful Widget for the Customer Registration/Edit Form
class CustomerFormBottomSheet extends StatefulWidget {
  final Customer? customerToEdit;
  final Function(Customer) onSubmitted; // Callback to send the Customer object back

  const CustomerFormBottomSheet({
    super.key,
    this.customerToEdit,
    required this.onSubmitted,
  });

  @override
  State<CustomerFormBottomSheet> createState() => _CustomerFormBottomSheetState();
}

class _CustomerFormBottomSheetState extends State<CustomerFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  String? _selectedGender;
  DateTime? _selectedBirthDate;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.customerToEdit?.firstName);
    _middleNameController = TextEditingController(text: widget.customerToEdit?.middleName);
    _lastNameController = TextEditingController(text: widget.customerToEdit?.lastName);
    _emailController = TextEditingController(text: widget.customerToEdit?.email);
    _phoneController = TextEditingController(text: widget.customerToEdit?.phone);
    _addressController = TextEditingController(text: widget.customerToEdit?.address);
    _selectedGender = widget.customerToEdit?.gender;
    _selectedBirthDate = widget.customerToEdit?.birthDate;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
        top: 20.0,
        left: 20.0,
        right: 20.0,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Wrap content tightly
            children: <Widget>[
              Text(
                widget.customerToEdit == null ? 'Register Customer' : 'Edit Customer',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width < 600 ? 20.0 : 24.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                controller: _middleNameController,
                decoration: const InputDecoration(labelText: 'Middle Name (Optional)'),
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15.0),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(labelText: 'Gender *'),
                items: <String>['Male', 'Female', 'Other'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() { // Update state within the bottom sheet
                    _selectedGender = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select gender';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15.0),
              // Use StateBuilder for the ListTile that shows the date,
              // so setState can rebuild just this part within the bottom sheet.
              ListTile(
                title: Text(
                  _selectedBirthDate == null
                      ? 'Pick Birth Date *'
                      : 'Birth Date: ${DateFormat('yyyy-MM-dd').format(_selectedBirthDate!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedBirthDate ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && picked != _selectedBirthDate) {
                    setState(() { // This setState correctly updates the ListTile's text
                      _selectedBirthDate = picked;
                    });
                    // After date is picked, trigger validation for birth date if the field is required
                    _formKey.currentState?.validate();
                  }
                },
              ),
              // Manual validator check for birth date during form submission
              // Removed redundant Builder, moved check to onPressed
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_selectedBirthDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please pick a birth date')),
                      );
                      return;
                    }

                    final customer = Customer(
                      id: widget.customerToEdit?.id ?? '', // ID handled by parent or generated
                      firstName: _firstNameController.text,
                      middleName: _middleNameController.text.isEmpty ? null : _middleNameController.text,
                      lastName: _lastNameController.text,
                      email: _emailController.text,
                      phone: _phoneController.text,
                      address: _addressController.text,
                      gender: _selectedGender!,
                      birthDate: _selectedBirthDate!,
                    );
                    widget.onSubmitted(customer); // Call the callback to pass data to parent
                  }
                },
                child: Text(widget.customerToEdit == null ? 'Submit' : 'Update'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}

// Extension to allow copying Customer objects, useful for updates
extension CustomerCopy on Customer {
  Customer copyWith({
    String? id,
    String? firstName,
    String? middleName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    String? gender,
    DateTime? birthDate,
  }) {
    return Customer(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
    );
  }
}
