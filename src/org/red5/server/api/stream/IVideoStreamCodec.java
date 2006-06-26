package org.red5.server.api.stream;

import org.apache.mina.common.ByteBuffer;

public interface IVideoStreamCodec {

	/**
	 * Return the name of the video codec.
	 */
	public String getName();
	
	/**
	 * Reset the codec to its initial state.
	 */
	public void reset();
	
	/**
	 * Returns true if the codec knows how to handle the passed
	 * stream data.
	 */
	public boolean canHandleData(ByteBuffer data);

	/**
	 * Update the state of the codec with the passed data.
	 */
	public boolean addData(ByteBuffer data);

	/**
	 * Return the data for a keyframe.
	 */
	public ByteBuffer getKeyframe();
}