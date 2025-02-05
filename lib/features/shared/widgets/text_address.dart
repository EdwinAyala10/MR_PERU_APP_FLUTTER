import 'package:crm_app/config/config.dart';
import 'package:flutter/material.dart';

class TextAddress extends StatelessWidget {
  String text;
  String? placeholder;
  String? error;
  BuildContext paramContext;
  Function()? callback;

  TextAddress(
      {super.key, required this.text, this.placeholder, this.error, required this.paramContext, this.callback});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          child: Row(
            children: [
              Expanded(
                /*child: CustomCompanyField(
                    label: 'Dirección',
                    initialValue: companyForm.direccion.value,
                    /*onChanged: ref
                        .read(companyFormProvider(company).notifier)
                        .onDireccionChanged,*/
                    errorMessage: companyForm.direccion.errorMessage,
                  ),*/
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 11.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: error != null ? Colors.red :  Colors.grey,
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    text == "" ? placeholder ?? '' : text,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: error != null ?  Colors.redAccent : Colors.black,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  splashColor: Colors.transparent,
                  /*onPressed: () {
                    showModalSearch(
                        context, ref, companyForm.rucId ?? '', 'direction');
                    //context.push('/company_map/${companyForm.rucId}/direction');
                  },*/
                  onPressed: callback,
                  icon: const Icon(Icons.location_on, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        error != null ?
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            error ?? '',
            textAlign: TextAlign.start,
            style: const TextStyle(color: Colors.red, fontSize: 13),
          ),
        ) : const SizedBox(),
      ],
    );
  }
}
