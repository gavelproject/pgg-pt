// CArtAgO artifact code for project pgg

package pgg;

import static jason.asSyntax.ASSyntax.createAtom;

import java.util.HashSet;
import java.util.Set;

import cartago.Artifact;
import cartago.INTERNAL_OPERATION;
import cartago.OPERATION;
import jason.asSyntax.Atom;

public class Pool extends Artifact {

  private enum Functor {
    CONTRIBUTED, PAYOFF, POOL_MEMBER, STATUS;

    @Override
    public String toString() {
      return name().toLowerCase();
    }
  }

  private int round;
  private Set<Atom> members;
  private Set<Atom> contributors;
  private int totalContribution = 0;

  private enum Status {
    INACTIVE, RUNNING, FINISHED
  }

  public void init() {
    members = new HashSet<>();
    contributors = new HashSet<>();
    defineObsProperty(Functor.STATUS.toString(), Status.INACTIVE.toString());
  }

  @OPERATION
  public void addMember(String playerName) {
    Atom player = createAtom(playerName);
    members.add(player);
    defineObsProperty(Functor.POOL_MEMBER.toString(), player, round);
  }

  @OPERATION
  public void contribute() {
    String agName = getCurrentOpAgentId().getAgentName();
    contributors.add(createAtom(agName));
  }

  @OPERATION
  public void multiplyContributions(int factor) {
    totalContribution = contributors.size() * factor;
  }

  @OPERATION
  public void disclosePayoff() {
    final float payoff = (float) totalContribution / members.size();
    defineObsProperty(Functor.PAYOFF.toString(), payoff);
  }

  @OPERATION
  public void discloseContributions() {
    contributors.forEach(contributor -> {
      defineObsProperty(Functor.CONTRIBUTED.toString(), contributor, round);
    });
  }

  @OPERATION
  private void run(int duration) {
    getObsProperty(Functor.STATUS.toString()).updateValue(Status.RUNNING.toString());
    await_time(duration);
    execInternalOp("finish");
  }

  @OPERATION
  public void setRound(int round) {
    this.round = round;
  }

  @INTERNAL_OPERATION
  public void finish() {
    getObsProperty(Functor.STATUS.toString()).updateValue(Status.FINISHED.toString());
  }

  @OPERATION
  public void clear() {
    round = 0;
    members.clear();
    contributors.clear();
    totalContribution = 0;
    removeObsProperty(Functor.CONTRIBUTED.toString());
    removeObsProperty(Functor.PAYOFF.toString());
    removeObsProperty(Functor.POOL_MEMBER.toString());
    getObsProperty(Functor.STATUS.toString()).updateValue(Status.INACTIVE.toString());;
  }
}

