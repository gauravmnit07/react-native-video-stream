/**
 * Created by buhe on 16/5/4.
 */
import React, {Component, PropTypes} from 'react';
import {
    requireNativeComponent,
    View
} from 'react-native';

class Player extends Component {

  constructor(props, context) {
    super(props, context);
    this._onLoading = this._onLoading.bind(this);
    this._onPaused = this._onPaused.bind(this);
    this._onShutdown = this._onShutdown.bind(this);
    this._onStreamError = this._onStreamError.bind(this);
    this._onPlaying = this._onPlaying.bind(this);
  }

  _onLoading(event) {
    this.props.onLoading && this.props.onLoading(event.nativeEvent);
  }

  _onPaused(event) {
    this.props.onPaused && this.props.onPaused(event.nativeEvent);
  }

  _onShutdown(event) {
    this.props.onShutdown && this.props.onShutdown(event.nativeEvent);
  }


  _onStreamError(event) {
    this.props.onStreamError && this.props.onStreamError(event.nativeEvent);
  }

  _onPlaying(event) {
    this.props.onPlaying && this.props.onPlaying(event.nativeEvent);
  }

  render() {
    const nativeProps = Object.assign({}, this.props);
    Object.assign(nativeProps, {
      onLoading: this._onLoading,
      onPaused: this._onPaused,
      onShutdown: this._onShutdown,
      onStreamError: this._onStreamError,
      onPlaying: this._onPlaying,
    });
    return (
        <RCTPlayer
    {...nativeProps}
  />
  )
  }
}

Player.propTypes = {
  source: PropTypes.shape({                          // 是否符合指定格式的物件
    uri: PropTypes.string.isRequired,
    controller: PropTypes.bool, //Android only
    timeout: PropTypes.number, //Android only
    hardCodec: PropTypes.bool, //Android only
    live: PropTypes.bool, //Android only
  }).isRequired,
  started:PropTypes.bool,
  muted:PropTypes.bool, //iOS only
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

  onLoading: PropTypes.func,
  onPaused: PropTypes.func,
  onShutdown: PropTypes.func,
  onStreamError: PropTypes.func,
  onPlaying: PropTypes.func,
    ...View.propTypes,
}

const RCTPlayer = requireNativeComponent('RCTPlayer', Player);

module.exports = Player;

//var iface = {
//      propTypes: {
//        ...View.propTypes,
//      source: PropTypes.object,
//      started:PropTypes.bool,
//      muted:PropTypes.bool, //iOS only
//    },
//    };
//
//module.exports = requireNativeComponent('RCTPlayer', iface);
