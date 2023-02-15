import 'package:chatgptflutter/constants/constants.dart';
import 'package:chatgptflutter/models/models_model.dart';
import 'package:chatgptflutter/providers/models_provider.dart';
import 'package:chatgptflutter/services/api_services.dart';
import 'package:chatgptflutter/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ModelsDropDownWidget extends StatefulWidget {
  const ModelsDropDownWidget({super.key});

  @override
  State<ModelsDropDownWidget> createState() => _ModelsDropDownWidgetState();
}

class _ModelsDropDownWidgetState extends State<ModelsDropDownWidget> {

  String? currentModel;

  @override
  Widget build(BuildContext context) {

    final modelProvider  = Provider.of<ModelsProvider>(context, listen: true);
    currentModel = modelProvider.getCurrentModel;

    return FutureBuilder<List<ModelsModel>>(
      future: modelProvider.getAllModels(),
      builder: ((context, snapshot) {
        if(snapshot.hasError){
          return Center(
            child: TextWidget(
              label: snapshot.error.toString(),
            ),
          );
        }

        return snapshot.data == null || snapshot.data!.isEmpty?
        const SizedBox.shrink():
        FittedBox(
          child: DropdownButton(
              dropdownColor: scaffoldBackgroundColor,
              iconEnabledColor: Colors.white,
              items: List<DropdownMenuItem<String>>.generate(
                snapshot.data!.length, 
              (index) => DropdownMenuItem(
                value: snapshot.data![index].id,
                child: TextWidget(
                label: snapshot.data![index].id,
                fontSize: 15,
              ))),
              value: currentModel,
              onChanged: (value){
                setState(() {
                  currentModel = value.toString();
                });
                modelProvider.setCurrentModel(value.toString());
              },
            ),
        );
        
      })
      );
  }
}

/**
 * DropdownButton(
      dropdownColor: scaffoldBackgroundColor,
      iconEnabledColor: Colors.white,
      items: getModelsItem,
      value: currentModel,
      onChanged: (value){
        currentModel = value.toString();
      },
    )
 */