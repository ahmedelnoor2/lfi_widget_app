import 'package:flutter/material.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

Widget leverageLevel(
  context,
  leverageLevelField,
  updateLeverageLevel,
  futureMarket,
  setState,
) {
  height = MediaQuery.of(context).size.height;
  width = MediaQuery.of(context).size.width;

  return Container(
    padding: EdgeInsets.all(10),
    height: height,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${futureMarket.activeMarket['symbol']} Contract Leverage Level',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.close,
                size: 20,
              ),
            )
          ],
        ),
        Container(
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              color: Color(0xff292C51),
            ),
            color: Color(0xff292C51),
            borderRadius: BorderRadius.all(
              Radius.circular(2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    leverageLevelField.text =
                        '${int.parse(leverageLevelField.text) - 1}';
                  });
                },
                child: Icon(
                  Icons.remove,
                  color: Color(0xff5E6292),
                ),
              ),
              SizedBox(
                width: width * 0.5,
                child: TextFormField(
                  onChanged: (value) {
                    setState(() {
                      leverageLevelField.text = '${int.parse(value)}';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Leverage level required to update.';
                    }
                    return null;
                  },
                  controller: leverageLevelField,
                  style: TextStyle(fontSize: 16),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    errorStyle: TextStyle(height: 0),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    hintStyle: TextStyle(
                      fontSize: 16,
                    ),
                    hintText:
                        "Leverage Level ${futureMarket.userConfiguration['nowLevel']}",
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    leverageLevelField.text =
                        '${int.parse(leverageLevelField.text) + 1}';
                  });
                },
                child: Icon(
                  Icons.add,
                  color: Color(0xff5E6292),
                ),
              ),
            ],
          ),
        ),
        SfSlider(
          min: double.parse(
              '${futureMarket.userConfiguration['minLevel'] ?? 0.00}'),
          max: double.parse(
              '${futureMarket.userConfiguration['maxLevel'] ?? 125.00}'),
          value: leverageLevelField.text.isEmpty
              ? 1.0
              : double.parse(leverageLevelField.text),
          interval: 31,
          showTicks: true,
          showLabels: true,
          enableTooltip: true,
          onChanged: (dynamic value) {
            setState(() {
              leverageLevelField.text =
                  '${int.parse('${value.toStringAsFixed(0)}')}';
            });
          },
        ),
        Container(
          padding: EdgeInsets.only(top: 15),
          child: Row(
            children: [
              // Text('Max holding amount is about ',
              //     style: TextStyle(fontSize: 15)),
              // Text(
              //   '${futureMarket.userConfiguration['leverCeiling']['${leverageLevelField.text}'] ?? 0} Cont.',
              //   style: TextStyle(fontSize: 15, color: Colors.amber),
              // )
            ],
          ),
        ),
        Container(
          width: width,
          padding: EdgeInsets.only(top: 10),
          child: ElevatedButton(
            onPressed: () {
              updateLeverageLevel(leverageLevelField.text);
              Navigator.pop(context);
            },
            child: Text('Confirm'),
          ),
        ),
      ],
    ),
  );
}
