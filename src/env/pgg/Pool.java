// CArtAgO artifact code for project pgg

package pgg;

import java.util.HashMap;
import java.util.Map;

import cartago.Artifact;
import cartago.OPERATION;

public class Pool extends Artifact {
  Map<String, Integer> contributions;

  public void init() {
    contributions = new HashMap<>();
  }

  @OPERATION
  public void addMember(String ag) {
    contributions.put(ag, 0);
    defineObsProperty("pool_member", getId().getName(), ag);
  }

  @OPERATION
  void contribute() {
    String agName = getCurrentOpAgentId().getAgentName();
    defineObsProperty("contributed", agName, getId().getName());
  }
//  
//  @Override
//  protected void dispose() {
//    removeObsProperty("contributed");
//    removeObsProperty("pool_member");
//    super.dispose();
//  }
}

