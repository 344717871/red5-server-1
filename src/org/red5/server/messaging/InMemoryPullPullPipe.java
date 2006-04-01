/*
 * RED5 Open Source Flash Server - http://www.osflash.org/red5
 * 
 * Copyright ? 2006 by respective authors (see below). All rights reserved.
 * 
 * This library is free software; you can redistribute it and/or modify it under the 
 * terms of the GNU Lesser General Public License as published by the Free Software 
 * Foundation; either version 2.1 of the License, or (at your option) any later 
 * version. 
 * 
 * This library is distributed in the hope that it will be useful, but WITHOUT ANY 
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
 * PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License along 
 * with this library; if not, write to the Free Software Foundation, Inc., 
 * 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA 
 */

package org.red5.server.messaging;

import java.util.Iterator;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * A simple in-memory version of pull-pull pipe.
 * It is triggered by an active consumer that pulls messages
 * through it from a pullable provider.
 * 
 * @author The Red5 Project (red5@osflash.org)
 * @author Steven Gong (steven.gong@gmail.com)
 */
public class InMemoryPullPullPipe extends AbstractPipe {
	private static final Log log = LogFactory.getLog(InMemoryPullPullPipe.class);
	
	public IMessage pullMessage() {
		IMessage message = null;
		synchronized (providers) {
			// choose the first available provider
			for (Iterator iter = providers.iterator(); iter.hasNext(); ) {
				IPullableProvider provider = (IPullableProvider) iter.next();
				try {
					message = provider.pullMessage();
					if (message != null) break;
				} catch (Throwable t) {
					log.error("exception when pulling message from provider", t);
				}
			}
		}
		return message;
	}

	public IMessage pullMessage(long wait) {
		IMessage message = null;
		synchronized (providers) {
			// divided evenly
			long averageWait = providers.size() > 0 ? wait / providers.size() : 0;
			// choose the first available provider
			for (Iterator iter = providers.iterator(); iter.hasNext(); ) {
				IPullableProvider provider = (IPullableProvider) iter.next();
				try {
					message = provider.pullMessage(averageWait);
					if (message != null) break;
				} catch (Throwable t) {
					log.error("exception when pulling message from provider", t);
				}
			}
		}
		return message;
	}

	public void pushMessage(IMessage message) {
		// push mode ignored
	}

}
