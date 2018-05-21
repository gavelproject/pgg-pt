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
package math;

import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

/**
 * @author igorcadelima
 * @see Math#floor(double)
 *
 */
public class floor extends DefaultInternalAction {
  private static InternalAction singleton = null;

  public final static InternalAction create() {
    if (singleton == null)
      singleton = new floor();
    return singleton;
  }

  @Override
  public int getMinArgs() {
    return 1;
  }

  @Override
  public int getMaxArgs() {
    return 2;
  }

  @Override
  protected void checkArguments(Term[] args) throws JasonException {
    super.checkArguments(args);
    if (!args[0].isNumeric()) {
      throw new JasonException("The first argument of the internal action "
          + getClass().getCanonicalName() + " is not a number.");
    } else if (!args[1].isVar()) {
      throw new JasonException("The second argument of the internal action "
          + getClass().getCanonicalName() + " is not a variable.");
    }
  }

  @Override
  public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
    checkArguments(args);
    double x = ((NumberTerm) args[0]).solve();
    final NumberTerm result = ASSyntax.createNumber(Math.floor(x));
    return un.unifies(result, args[1]);
  }
}
