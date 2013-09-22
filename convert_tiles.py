#!/usr/bin/python

import os, sys
from xml.dom import minidom

#--------------------------------------
BASE_PATH = os.path.dirname(__file__)
MAP_SRC_DIR = os.path.join(BASE_PATH, 'assets/levels')
MAP_COMPILED_DIR = os.path.join(BASE_PATH, 'assets/levels/compiled')
TILE_LAYER_NAMES = ["ground"]
#--------------------------------------

def compile_levels():
    """
    Flatten OGMO's XML tilemaps into comma-separated strings. This is
    done in order to cut down processing at runtime - parsing tilemap
    data from a list of xml nodes into a CSV is too costly to do at
    runtime without noticeable lag.
    """
    
    for ogmo_filename in [x for x in os.listdir(MAP_SRC_DIR) if x.endswith('.oel')]:
        ogmo_path = os.path.join(MAP_SRC_DIR, ogmo_filename)
        ogmo_flattened_path = os.path.join(MAP_COMPILED_DIR, ogmo_filename)

        if os.path.exists(ogmo_flattened_path):
            if os.path.getmtime(ogmo_flattened_path) > os.path.getmtime(ogmo_path):
                sys.stdout.write("--%s up to date\n" % ogmo_flattened_path)
                continue
        
        flatten_ogmo_tilemaps(ogmo_path, ogmo_flattened_path)

def flatten_ogmo_tilemaps(ogmo_path, ogmo_flattened_path):
    ogmo_dom = minidom.parse(ogmo_path)

    map_data = dict(ogmo_dom.getElementsByTagName('level')[0].attributes.items())
    map_data['width'] = ogmo_dom.getElementsByTagName('width')[0].firstChild.data
    map_data['height'] = ogmo_dom.getElementsByTagName('height')[0].firstChild.data
    
    # load tiles
    for tile_layer_name in TILE_LAYER_NAMES:
        map_data[tile_layer_name] = dict(ogmo_dom.getElementsByTagName(tile_layer_name)[0].attributes.items())
        map_data[tile_layer_name]['tiles'] = ''

        tileWidth = int(map_data[tile_layer_name]['tileWidth'])
        tileHeight = int(map_data[tile_layer_name]['tileHeight'])
        widthInTiles = int(map_data['width']) / tileWidth
        heightInTiles = int(map_data['height']) / tileHeight

        tiles = {}
        for tileNode in ogmo_dom.getElementsByTagName(tile_layer_name)[0].getElementsByTagName('tile'):
            tileId = tileNode.getAttribute('id')
            tileX = int(tileNode.getAttribute('x')) / tileWidth
            tileY = int(tileNode.getAttribute('y')) / tileHeight
            tiles[str(tileX) + '@' + str(tileY)] = tileId

        for y in range(0, heightInTiles):
            for x in range(0, widthInTiles):
                tileId = tiles.get(str(x) + '@' + str(y), '0')
                map_data[tile_layer_name]['tiles'] += tileId
                map_data[tile_layer_name]['tiles'] += ","
            map_data[tile_layer_name]['tiles'] += "\n"

        # clear out old tiles node & add a new flattened one
        ogmo_dom.getElementsByTagName(tile_layer_name)[0].childNodes[:] = [] # shorcut to clear all child nodes
        flattenedTextNode = ogmo_dom.createTextNode(map_data[tile_layer_name]['tiles'])
        ogmo_dom.getElementsByTagName(tile_layer_name)[0].appendChild(flattenedTextNode)

    f = open(ogmo_flattened_path, 'w')
    f.write(ogmo_dom.toxml())
    f.close()
    
if __name__ == '__main__':
    compile_levels()