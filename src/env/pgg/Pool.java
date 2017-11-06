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
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import cartago.Artifact;
import cartago.OPERATION;
import jason.asSyntax.Atom;

public class Pool extends Artifact {
  private Set<Atom> members;
  private Map<Atom, Integer> contributions;
  private int totalContribution = 0;

  private enum Functor {
    CONTRIBUTION, CONTRIBUTIONS_RECEIVED, PAYOFF, POOL_MEMBER, POOL_STATUS;

    @Override
    public String toString() {
      return name().toLowerCase();
    }
  }

  private enum Status {
    INACTIVE, RUNNING, FINISHED
  }

  public void init() {
    members = new HashSet<>();
    contributions = new HashMap<>();
    defineObsProperty(Functor.POOL_STATUS.toString(), Status.INACTIVE.toString());
  }

  @OPERATION
  public void addMember(String playerName) {
    Atom player = createAtom(playerName);
    members.add(player);
    defineObsProperty(Functor.POOL_MEMBER.toString(), player);
  }

  @OPERATION
  public void contribute(int value) {
    String agName = getCurrentOpAgentId().getAgentName();
    totalContribution += value;
    contributions.put(createAtom(agName), value);
    if (contributions.size() == members.size()) {
      signal(getCreatorId(), Functor.CONTRIBUTIONS_RECEIVED.toString());
    }
  }

  @OPERATION
  public void multiplyContributions(int factor) {
    totalContribution *= factor;
  }

  @OPERATION
  public void disclosePayoff() {
    final float payoff = (float) totalContribution / members.size();
    defineObsProperty(Functor.PAYOFF.toString(), payoff);
  }

  @OPERATION
  public void discloseContributions() {
    contributions.forEach((player, value) -> {
      defineObsProperty(Functor.CONTRIBUTION.toString(), player, value);
    });
  }

  @OPERATION
  private void run() {
    getObsProperty(Functor.POOL_STATUS.toString()).updateValue(Status.RUNNING.toString());
  }

  @OPERATION
  public void finish() {
    getObsProperty(Functor.POOL_STATUS.toString()).updateValue(Status.FINISHED.toString());
  }

  @OPERATION
  public void clear() {
    if (!members.isEmpty()) {
      for (int i = 0; i < members.size(); i++) {
        removeObsProperty(Functor.CONTRIBUTION.toString());
        removeObsProperty(Functor.POOL_MEMBER.toString());
      }
      removeObsProperty(Functor.PAYOFF.toString());
      members.clear();
      contributions.clear();
      totalContribution = 0;
    }
    getObsProperty(Functor.POOL_STATUS.toString()).updateValue(Status.INACTIVE.toString());
  }
}
