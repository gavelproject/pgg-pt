// CArtAgO artifact code for project pgg

package pgg;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import cartago.Artifact;
import cartago.OPERATION;

public class Pool extends Artifact {
  private Map<String, Integer> contributions;
  private Set<String> members;
  private int contribution = 0;

  public void init() {
    contributions = new HashMap<>();
    members = new HashSet<>();
  }

  @OPERATION
  public void addMember(String ag) {
    contributions.put(ag, 0);
    members.add(ag);
    defineObsProperty("pool_member", getId().getName(), ag);
  }

  @OPERATION
  public void contribute() {
    String agName = getCurrentOpAgentId().getAgentName();
    defineObsProperty("contributed", agName, getId().getName());
    contribution++;
  }

  @OPERATION
  public void multiplyContributions(int factor) {
    contribution *= factor;
  }

  @OPERATION
  public void distributeEarnings() {
    final float earning = (float) contribution / members.size();
    members.forEach(ag -> {
      signal("earning", earning);
      await_time(0);
    });
  }
}

