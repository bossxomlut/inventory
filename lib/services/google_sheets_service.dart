import 'dart:async';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;

class ColumnWidthConfig {
  const ColumnWidthConfig({
    required this.startIndex,
    required this.endIndex,
    required this.pixelSize,
  });

  final int startIndex;
  final int endIndex;
  final int pixelSize;
}

class GoogleSheetsService {
  Future<T> _withSheetsApi<T>({
    required GoogleSignInAccount account,
    required List<String> scopes,
    required Future<T> Function(sheets.SheetsApi api) action,
  }) async {
    final auth = await account.authorizationClient.authorizeScopes(scopes);
    final client = auth.authClient(scopes: scopes);
    final api = sheets.SheetsApi(client);
    try {
      return await action(api);
    } finally {
      client.close();
    }
  }

  Future<int> ensureSheet({
    required GoogleSignInAccount account,
    required String spreadsheetId,
    required String sheetTitle,
  }) async {
    final result = await _withSheetsApi(
      account: account,
      scopes: <String>[sheets.SheetsApi.spreadsheetsScope],
      action: (api) => api.spreadsheets.get(
        spreadsheetId,
        $fields: 'sheets.properties(sheetId,title)',
      ),
    );
    final sheetList = result.sheets ?? <sheets.Sheet>[];
    final existing = sheetList.firstWhere(
      (sheet) => sheet.properties?.title == sheetTitle,
      orElse: () => sheets.Sheet(),
    );
    final existingId = existing.properties?.sheetId;
    if (existingId != null) {
      return existingId;
    }
    if (sheetList.length == 1) {
      final sheetId = sheetList.first.properties?.sheetId;
      if (sheetId != null) {
        await _withSheetsApi(
          account: account,
          scopes: <String>[sheets.SheetsApi.spreadsheetsScope],
          action: (api) => api.spreadsheets.batchUpdate(
            sheets.BatchUpdateSpreadsheetRequest(
              requests: <sheets.Request>[
                sheets.Request(
                  updateSheetProperties: sheets.UpdateSheetPropertiesRequest(
                    properties: sheets.SheetProperties(
                      sheetId: sheetId,
                      title: sheetTitle,
                    ),
                    fields: 'title',
                  ),
                ),
              ],
            ),
            spreadsheetId,
          ),
        );
        return sheetId;
      }
    }
    final response = await _withSheetsApi(
      account: account,
      scopes: <String>[sheets.SheetsApi.spreadsheetsScope],
      action: (api) => api.spreadsheets.batchUpdate(
        sheets.BatchUpdateSpreadsheetRequest(
          requests: <sheets.Request>[
            sheets.Request(
              addSheet: sheets.AddSheetRequest(
                properties: sheets.SheetProperties(title: sheetTitle),
              ),
            ),
          ],
        ),
        spreadsheetId,
      ),
    );
    final createdId = response.replies
        ?.firstWhere(
          (reply) => reply.addSheet != null,
          orElse: () => sheets.Response(),
        )
        .addSheet
        ?.properties
        ?.sheetId;
    if (createdId != null) {
      return createdId;
    }
    final refreshed = await _withSheetsApi(
      account: account,
      scopes: <String>[sheets.SheetsApi.spreadsheetsScope],
      action: (api) => api.spreadsheets.get(
        spreadsheetId,
        $fields: 'sheets.properties(sheetId,title)',
      ),
    );
    final refreshedSheet = refreshed.sheets?.firstWhere(
      (sheet) => sheet.properties?.title == sheetTitle,
      orElse: () => sheets.Sheet(),
    );
    final refreshedId = refreshedSheet?.properties?.sheetId;
    if (refreshedId == null) {
      throw StateError('Sheet "$sheetTitle" not found after creation.');
    }
    return refreshedId;
  }

  Future<int> writeValues({
    required GoogleSignInAccount account,
    required String spreadsheetId,
    required String sheetTitle,
    required List<List<Object?>> values,
  }) async {
    final sheetId = await ensureSheet(
      account: account,
      spreadsheetId: spreadsheetId,
      sheetTitle: sheetTitle,
    );
    await _withSheetsApi(
      account: account,
      scopes: <String>[sheets.SheetsApi.spreadsheetsScope],
      action: (api) => api.spreadsheets.values.update(
        sheets.ValueRange(values: values),
        spreadsheetId,
        '$sheetTitle!A1',
        valueInputOption: 'USER_ENTERED',
      ),
    );
    return sheetId;
  }

  Future<List<List<Object?>>> readValues({
    required GoogleSignInAccount account,
    required String spreadsheetId,
    required String sheetTitle,
  }) async {
    final result = await _withSheetsApi(
      account: account,
      scopes: <String>[sheets.SheetsApi.spreadsheetsReadonlyScope],
      action: (api) => api.spreadsheets.values.get(
        spreadsheetId,
        sheetTitle,
        majorDimension: 'ROWS',
      ),
    );
    return result.values ?? <List<Object?>>[];
  }

  Future<void> formatImageColumn({
    required GoogleSignInAccount account,
    required String spreadsheetId,
    required int sheetId,
    required int imageColumnIndex,
    required int imageColumnCount,
    required int rowCount,
    int rowHeight = 90,
    int columnWidth = 100,
  }) async {
    if (imageColumnCount <= 0) {
      return;
    }
    final requests = <sheets.Request>[
      sheets.Request(
        updateDimensionProperties: sheets.UpdateDimensionPropertiesRequest(
          range: sheets.DimensionRange(
            sheetId: sheetId,
            dimension: 'COLUMNS',
            startIndex: imageColumnIndex,
            endIndex: imageColumnIndex + imageColumnCount,
          ),
          properties: sheets.DimensionProperties(pixelSize: columnWidth),
          fields: 'pixelSize',
        ),
      ),
    ];

    if (rowCount > 1) {
      requests.add(
        sheets.Request(
          updateDimensionProperties: sheets.UpdateDimensionPropertiesRequest(
            range: sheets.DimensionRange(
              sheetId: sheetId,
              dimension: 'ROWS',
              startIndex: 1,
              endIndex: rowCount,
            ),
            properties: sheets.DimensionProperties(pixelSize: rowHeight),
            fields: 'pixelSize',
          ),
        ),
      );
    }

    await _withSheetsApi(
      account: account,
      scopes: <String>[sheets.SheetsApi.spreadsheetsScope],
      action: (api) => api.spreadsheets.batchUpdate(
        sheets.BatchUpdateSpreadsheetRequest(requests: requests),
        spreadsheetId,
      ),
    );
  }

  Future<void> formatColumnWidths({
    required GoogleSignInAccount account,
    required String spreadsheetId,
    required int sheetId,
    required List<ColumnWidthConfig> columns,
  }) async {
    if (columns.isEmpty) {
      return;
    }
    final List<sheets.Request> requests = columns
        .map(
          (config) => sheets.Request(
            updateDimensionProperties:
                sheets.UpdateDimensionPropertiesRequest(
              range: sheets.DimensionRange(
                sheetId: sheetId,
                dimension: 'COLUMNS',
                startIndex: config.startIndex,
                endIndex: config.endIndex,
              ),
              properties: sheets.DimensionProperties(
                pixelSize: config.pixelSize,
              ),
              fields: 'pixelSize',
            ),
          ),
        )
        .toList();

    await _withSheetsApi(
      account: account,
      scopes: <String>[sheets.SheetsApi.spreadsheetsScope],
      action: (api) => api.spreadsheets.batchUpdate(
        sheets.BatchUpdateSpreadsheetRequest(requests: requests),
        spreadsheetId,
      ),
    );
  }

  Future<void> allowExternalUrlAccess({
    required GoogleSignInAccount account,
    required String spreadsheetId,
  }) async {
    await _withSheetsApi(
      account: account,
      scopes: <String>[sheets.SheetsApi.spreadsheetsScope],
      action: (api) => api.spreadsheets.batchUpdate(
        sheets.BatchUpdateSpreadsheetRequest(
          requests: <sheets.Request>[
            sheets.Request(
              updateSpreadsheetProperties:
                  sheets.UpdateSpreadsheetPropertiesRequest(
                properties: sheets.SpreadsheetProperties(
                  importFunctionsExternalUrlAccessAllowed: true,
                ),
                fields: 'importFunctionsExternalUrlAccessAllowed',
              ),
            ),
          ],
        ),
        spreadsheetId,
      ),
    );
  }
}
