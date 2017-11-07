/*******************************************************************************
 * MIT License
 *
 * Copyright (c) Igor Conrado Alves de Lima <igorcadelima@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 * associated documentation files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge, publish, distribute,
 * sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or
 * substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
 * NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *******************************************************************************/
package pgg;

import static jason.asSyntax.ASSyntax.createAtom;

import java.util.HashMap;
import java.util.Map;

import cartago.Artifact;
import cartago.OPERATION;
import cartago.ObsProperty;
import jason.asSyntax.Atom;

/**
 * @author igorcadelima
 *
 */
public class ImageDb extends Artifact {
  private double gossipWeight;
  private double interactionWeight;

  private double gossipImg = -1;
  private double interactionImg = -1;

  private final Map<Atom, Map<Integer, Integer>> interactions = new HashMap<>();
  private final Map<Atom, Map<Atom, Double>> gossips = new HashMap<>();

  public void init(double gw, double iw) {
    gossipWeight = gw;
    interactionWeight = iw;
  }

  @OPERATION
  public void putGossip(String target, String sender, double imgValue) {
    Atom targetAtom = createAtom(target);
    Atom senderAtom = createAtom(sender);
    Map<Atom, Double> entries = gossips.get(targetAtom);
    if (entries == null) {
      Map<Atom, Double> newEntry = new HashMap<>();
      newEntry.put(senderAtom, imgValue);
      gossips.put(targetAtom, newEntry);
    } else {
      entries.put(senderAtom, imgValue);
    }
    updateGossipImg(targetAtom);
    updateOverallImg(targetAtom);
  }

  @OPERATION
  public void addInteraction(String target, int round, int contribution) {
    Atom targetAtom = createAtom(target);
    Map<Integer, Integer> entryMap = interactions.get(targetAtom);
    if (entryMap == null) {
      entryMap = new HashMap<>();
      interactions.put(targetAtom, entryMap);
    }
    entryMap.put(round, contribution);
    updateInteractionImg(targetAtom);
    updateOverallImg(targetAtom);
  }

  private void updateGossipImg(Atom target) {
    gossipImg = gossips.get(target)
                       .values()
                       .stream()
                       .mapToDouble(v -> v)
                       .average()
                       .getAsDouble();
  }

  private void updateInteractionImg(Atom target) {
    interactionImg = interactions.get(target)
                                 .values()
                                 .stream()
                                 .mapToLong(v -> v)
                                 .average()
                                 .getAsDouble();
  }

  private void updateOverallImg(Atom target) {
    double overallImg;
    if (interactions.isEmpty()) {
      overallImg = gossipImg;
    } else if (gossips.isEmpty()) {
      overallImg = interactionImg;
    } else {
      overallImg = (interactionWeight * interactionImg) + (gossipWeight * gossipImg);
    }

    ObsProperty overallProp = getObsPropertyByTemplate("overall_img", target, null);
    if (overallProp == null) {
      defineObsProperty("overall_img", target, overallImg);
    } else {
      overallProp.updateValue(1, overallImg);
    }
  }
}
