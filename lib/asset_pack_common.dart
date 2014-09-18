/*
  Copyright (C) 2013 John McCutchan <john@johnmccutchan.com>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/

/// Part of the asset_pack package that is shared between browser and standalone
/// VM code.
library asset_pack_common;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

part 'src/asset_pack_common/asset_pack_file.dart';
part 'src/asset_pack_common/asset_pack_trace.dart';
part 'src/asset_pack_common/asset.dart';
part 'src/asset_pack_common/asset_importer.dart';
part 'src/asset_pack_common/asset_manager.dart';
part 'src/asset_pack_common/asset_pack.dart';
part 'src/asset_pack_common/decoders/base_64_decoder.dart';
part 'src/asset_pack_common/importers/json_importer.dart';
part 'src/asset_pack_common/importers/noop_importer.dart';
part 'src/asset_pack_common/importers/pack_importer.dart';
part 'src/asset_pack_common/importers/text_importer.dart';
part 'src/asset_pack_common/asset_loader.dart';