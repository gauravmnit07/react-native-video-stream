/**
 * Created by buhe on 16/4/29.
 */
import React, {PropTypes, Component} from 'react';
import {requireNativeComponent, Dimensions, NativeModules, View} from 'react-native';
//
// class Stream extends Component {
// 	static propTypes = {
//
// 	};
//
// 	render() {
// 		return (
// 			<RCTStream
// 				{...this.props}
// 			/>
// 		)
// 	}
// }
const { width , height } = Dimensions.get('window');

class Stream extends Component {
	constructor(props, context){
		super(props, context);
		this._onReady = this._onReady.bind(this);
		this._onPending = this._onPending.bind(this);
		this._onStart = this._onStart.bind(this);
		this._onStreamError = this._onStreamError.bind(this);
		this._onStreamingStopped = this._onStreamingStopped.bind(this);
	}

	static propTypes = {
		started: PropTypes.bool,
		cameraFronted: PropTypes.bool,
		url: PropTypes.string.isRequired,
		landscape: PropTypes.bool.isRequired,
		videoConfig:PropTypes.shape({
	    videoBitRate: PropTypes.number,
	    videoMaxBitRate: PropTypes.number,
	    videoMinBitRate: PropTypes.number,
	    videoFrameRate: PropTypes.number,
	    videoMaxFrameRate: PropTypes.number,
	    videoMinFrameRate: PropTypes.number,
	    sessionPreset: PropTypes.oneOf([0, 1, 2]), // SessionPreset360x640 = 0, SessionPreset540x960 = 1, SessionPreset720x1280 = 2
	  }),
	  audioConfig:PropTypes.shape({
	    numberOfChannels: PropTypes.number,
	    audioSampleRate: PropTypes.number,
	    audioBitRate: PropTypes.number,
	  }),

		onReady: PropTypes.func,
		onPending: PropTypes.func,
		onStart: PropTypes.func,
		onStreamError: PropTypes.func,
		onStreamingStopped: PropTypes.func,
		...View.propTypes,
	}

	static defaultProps= {
		cameraFronted: true
	}

	_onReady(event){
		this.props.onReady && this.props.onReady(event.nativeEvent);
	}

	_onPending(event) {
		this.props.onPending && this.props.onPending(event.nativeEvent);
	}

	_onStart(event) {
		this.props.onStart && this.props.onStart(event.nativeEvent);
	}

	_onStreamError(event) {
		this.props.onStreamError && this.props.onStreamError(event.nativeEvent);
	}

	_onStreamingStopped(event) {
		this.props.onStreamingStopped && this.props.onStreamingStopped(event.nativeEvent);
	}

	render() {
		let style = this.props.style;
		if(this.props.style){
			if(this.props.landscape){
				style = {
					...this.props.style,
					transform:[{rotate:'270deg'}],
					width:height,
					height:width
				};
			}else{
				style = {
					width: width,
					height: height,
					...this.props.style
				}
			}
		}
		const nativeProps = {
			onReady: this._onReady,
			onPending: this._onPending,
			onStart: this._onStart,
			onStreamError: this._onStreamError,
			onStreamingStopped: this._onStreamingStopped,
			onStop: this._onStreamingStopped,
			...this.props,
			style: {
				...style
			}
		};

		return (
			<RCTStream
				{...nativeProps}
			/>
		)
	}
}

const RCTStream = requireNativeComponent('RCTStream', Stream);

module.exports = Stream;
