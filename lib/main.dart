import 'dart:convert';
import 'dart:io'; // Adicionado para usar File
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Form Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DynamicFormPage(),
    );
  }
}

class DynamicFormPage extends StatefulWidget {
  @override
  _DynamicFormPageState createState() => _DynamicFormPageState();
}

class _DynamicFormPageState extends State<DynamicFormPage> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _formData = {};
  List<dynamic> _campos = [];

  DateTime date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadCampos();
  }

  Future<void> _loadCampos() async {
    String jsonString = await rootBundle.loadString('assets/campos.json');
    setState(() {
      _campos = jsonDecode(jsonString)['campos'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dynamic Form Demo'),
      ),
      body: _campos.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: _campos.map<Widget>((campo) {
                    return buildField(campo);
                  }).toList(),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            print('Formulário válido. Dados: ${jsonEncode(_formData)}');
            // Aqui você pode salvar os dados em um novo JSON ou fazer o que precisar com eles
          }
        },
        child: Icon(Icons.save),
      ),
    );
  }

  Widget buildField(Map<String, dynamic> campo) {
    switch (campo['tipo']) {
      case 'TEXTO':
        return TextFormField(
          decoration: InputDecoration(
              labelText: campo['titulo'],
              filled: true,
              enabledBorder:
                  const OutlineInputBorder(borderSide: BorderSide.none),
              focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal))),
          onSaved: (value) => _formData[campo['nome']] = value,
          inputFormatters: [MaskTextInputFormatter(mask: campo['mascara'])],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, preencha este campo';
            }
            return null;
          },
          maxLength: campo['tamanhoMaximo'],
        );
      case 'INTEIRO':
        return TextFormField(
          decoration: InputDecoration(
              labelText: campo['titulo'],
              filled: true,
              enabledBorder:
                  const OutlineInputBorder(borderSide: BorderSide.none),
              focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue))),
          keyboardType: TextInputType.number,
          onSaved: (value) => _formData[campo['nome']] = int.parse(value!),
          inputFormatters: [MaskTextInputFormatter(mask: campo['mascara'])],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, preencha este campo';
            }
            return null;
          },
          maxLength: campo['tamanhoMaximo'],
        );
      case 'DECIMAL':
        return TextFormField(
          decoration: InputDecoration(
              labelText: campo['titulo'],
              filled: true,
              enabledBorder:
                  const OutlineInputBorder(borderSide: BorderSide.none),
              focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue))),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onSaved: (value) => _formData[campo['nome']] = double.parse(value!),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, preencha este campo';
            }
            return null;
          },
          maxLength: campo['tamanhoMaximo'],
        );
      case 'DATA':
        return TextFormField(
          decoration: InputDecoration(
              labelText: campo['titulo'],
              filled: true,
              enabledBorder:
                  const OutlineInputBorder(borderSide: BorderSide.none),
              focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue))),
          onSaved: (value) => _formData[campo['nome']] = value!,
          inputFormatters: [MaskTextInputFormatter(mask: campo['mascara'])],
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, preencha este campo';
            }
            return null;
          },
          maxLength: campo['tamanhoMaximo'],
        );
      case 'HORA':
        return TextFormField(
          decoration: InputDecoration(
              labelText: campo['titulo'],
              filled: true,
              enabledBorder:
                  const OutlineInputBorder(borderSide: BorderSide.none),
              focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue))),
          keyboardType: TextInputType.datetime,
          onSaved: (value) => _formData[campo['nome']] = value,
          inputFormatters: [MaskTextInputFormatter(mask: campo['mascara'])],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, preencha este campo';
            }
            return null;
          },
          maxLength: campo['tamanhoMaximo'],
        );
      case 'CHECKBOX':
        return CheckboxListTile(
          title: Text(campo['titulo']),
          value: _formData[campo['nome']] ?? false,
          onChanged: (value) {
            setState(() {
              _formData[campo['nome']] = value;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
        );
      case 'SELECAO':
        List<String> opcoes = List<String>.from(campo['opcoes']);
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
              labelText: campo['titulo'],
              filled: true,
              enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue))),
          value: _formData[campo['nome']],
          items: opcoes.map((opcao) {
            return DropdownMenuItem<String>(
              value: opcao,
              child: Text(opcao),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _formData[campo['nome']] = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, selecione uma opção';
            }
            return null;
          },
          onSaved: (value) => _formData[campo['nome']] = value,
        );
      case 'IMAGEM':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              campo['titulo'],
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: _formData[campo['nome']] != null
                      ? Image.file(
                          File(_formData[
                              campo['nome']]), // Convertendo para File
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 100,
                          width: 100,
                          color: Colors.grey[200],
                          child: Icon(Icons.camera_alt),
                        ),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: campo['opcoes'] == 'camera'
                          ? ImageSource.camera
                          : ImageSource.gallery,
                    );
                    if (pickedFile != null) {
                      setState(() {
                        _formData[campo['nome']] = pickedFile.path;
                      });
                    }
                  },
                  child: Text(
                    campo['opcoes'] == 'camera' ? 'Tirar Foto' : 'Galeria',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
