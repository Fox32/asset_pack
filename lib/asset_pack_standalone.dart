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

/// asset_pack library based on dart:io.
library asset_pack_standalone;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:asset_pack/asset_pack_common.dart';
export 'package:asset_pack/asset_pack_common.dart';

part 'src/asset_pack_standalone/asset_manager_standalone.dart';
part 'src/asset_pack_standalone/asset_loader_standalone.dart';
part 'src/asset_pack_standalone/loaders/map_loader.dart';
part 'src/asset_pack_standalone/loaders/text_loader.dart';
