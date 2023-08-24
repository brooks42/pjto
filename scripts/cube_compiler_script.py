#!/usr/bin/env python

# xml parsing help from https://www.geeksforgeeks.org/reading-and-writing-xml-files-in-python/?ref=lbp
# to run you need to do
# `pip3 install beautifulsoup4`
# `pip3 install lxml`

import sys
import json

from bs4 import BeautifulSoup


def main():
    """ 
    compiles the set of cards in ../pjto_cockatrice.xml into a cube format

    cube format is just a file with the card names, with repeated card names for commons

    so for example

    Agatha
    Gyarados
    Eevee
    Eevee 
    """

    try:
        # sys.argv[1] is expected to be -f for bash reasons
        filename = sys.argv[2]

        # open the input file as XML, input is assumed to be a cockatrice card file
        print("Loading file...")
        cube_list = list()

        with open(filename, "r") as f:
            soup_obj = BeautifulSoup(f, "xml")

            # grab the list of cards out of the input cockatrice xml file
            all_cards = soup_obj.findAll("card")

            print("Going through all of the cards: ", len(all_cards))

            all_card_types = dict()
            all_card_colors = dict()

            for index in range(len(all_cards)):

                # grab the info and transform this into the Card instance format above
                cockatrice_card = all_cards[index]

                for name_tag in cockatrice_card:
                    if name_tag.name == 'name':
                        card_name = name_tag.string
                        card_type = ''
                        card_color = 'colorless'

                        if card_name == 'Mewtwo, Redeemed':
                            continue

                        # skip DFCs since they don't need to be in the cube file
                        if '(DFC)' in card_name:
                            continue

                        basicland = False
                        pokemon = False
                        emblemOrToken = False
                        for type_tag in cockatrice_card:
                            if type_tag.name == 'type':
                                card_type = type_tag.string

                                if 'Basic Land' in card_type:
                                    basicland = True
                                if 'Pokémon' in card_type:
                                    pokemon = True
                                if 'Emblem' in card_type or 'Token' in card_type:
                                    emblemOrToken = True

                                all_card_types[card_type] = all_card_types.get(
                                    card_type, 0) + 1

                        if basicland:
                            continue

                        # append (PJTO) to the card name to work with dr4ft
                        for set_tag in cockatrice_card:
                            if set_tag.name == 'set':
                                card_name = f'{card_name} ({set_tag.string})'

                        if not emblemOrToken:
                            for color_tag in cockatrice_card:
                                if color_tag.name == 'color':
                                    if color_tag.string == "null" or color_tag.string == None:
                                        card_color = 'colorless'
                                    else:
                                        card_color = color_tag.string

                        # only append non-token rarities, and append twice if rarity is common
                        for rarity_tag in cockatrice_card:
                            if rarity_tag.name == 'set':

                                if rarity_tag['rarity'] == 'token':
                                    continue

                                cube_list.append(card_name)
                                all_card_colors[card_color] = all_card_colors.get(
                                    card_color, 0) + 1

                                if rarity_tag['rarity'] == 'common' and pokemon:
                                    cube_list.append(card_name)
                                    all_card_colors[card_color] = all_card_colors.get(
                                        card_color, 0) + 1

        cube_list.sort()

        print(f'Writing {len(all_card_colors)} cards to cube file...')
        print(f'{json.dumps(all_card_colors)}')

        print(f'Writing {len(cube_list)} cards to cube file...')
        with open('pjto_cube.txt', 'w') as f:
            f.write('\n'.join(str(item) for item in cube_list))

        print('Done')

    except Exception as e:
        print(f"Exception: {e}")
        print("Usage: python3 cube_compiler_script -f filename")


if __name__ == "__main__":
    main()
